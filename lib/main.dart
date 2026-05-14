import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'package:just_audio_background/just_audio_background.dart';

import 'models/prayer_tracking_model.dart';
import 'providers/dzikir_provider.dart';
import 'services/prayer_calculation_service.dart';
import 'providers/murottal_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tracking_provider.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
import 'services/iap_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

// ── Qibla sensor block keys ──────────────────────────────────────────────────
// Mirror QiblaScreen constants so PlatformDispatcher.onError can persist
// failure counts for native Azimuth NaN throws that bypass Dart-level
// qiblahStream onError handlers.
const String _kQiblaBlockedKey   = 'qibla_sensor_blocked';
const String _kQiblaFailCountKey = 'qibla_sensor_fail_count';
const int    _kQiblaMaxFailures  = 3;

// ── WorkManager background task ───────────────────────────────────────────────
//
// Runs every 15 minutes (Android minimum) to refresh the home-screen widget
// countdown. The Kotlin providers recompute the countdown from the stored
// next_prayer_millis value, so no Dart-side prayer calculation is needed.

const _kWidgetTaskName = 'prayer_widget_update';

@pragma('vm:entry-point')
void _workmanagerDispatcher() {
  Workmanager().executeTask((task, _) async {
    // Trigger a redraw on both widget sizes — Kotlin providers compute
    // the fresh countdown from the already-saved next_prayer_millis.
    await Future.wait([
      HomeWidget.updateWidget(androidName: 'PrayerWidgetSmallProvider'),
      HomeWidget.updateWidget(androidName: 'PrayerWidgetMediumProvider'),
    ]);
    return true;
  });
}

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ── Firebase init (must be before anything that may throw) ──────────────
  // Crashlytics is disabled in debug builds so noisy dev errors don't pollute
  // the production crash dashboard.
  try {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Catch all uncaught Flutter framework errors.
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Catch all uncaught async errors that aren't handled by the framework.
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final stackStr = stack.toString();
      final isAzimuthNaN = stackStr.contains('Azimuth') &&
          (stackStr.contains('Degrees must be finite') || stackStr.contains('NaN'));

      if (isAzimuthNaN) {
        // Record non-fatal so it doesn't tank crash-free rate. The user's
        // session can recover (next sample or app restart) — this isn't a
        // permanent app failure.
        FirebaseCrashlytics.instance.recordError(
          error, stack,
          reason: 'qibla_native_azimuth_nan',
          fatal: false,
        );
        // Increment persistent failure counter so QiblaScreen skips subscribe
        // on next open after threshold (currently 3). Wrapped in try/catch
        // because the settings box may not be open if this fires very early
        // in boot — that's a tolerable miss; subsequent failures will record.
        try {
          final box = Hive.box('settings');
          final newCount =
              (box.get(_kQiblaFailCountKey, defaultValue: 0) as int) + 1;
          box.put(_kQiblaFailCountKey, newCount);
          if (newCount >= _kQiblaMaxFailures) {
            box.put(_kQiblaBlockedKey, true);
          }
          FirebaseCrashlytics.instance
              .setCustomKey('qibla_fail_count', newCount);
          FirebaseCrashlytics.instance
              .setCustomKey('qibla_blocked', newCount >= _kQiblaMaxFailures);
        } catch (_) {
          // settings box not open yet — accept the miss.
        }
        return true;
      }

      // All other uncaught async errors — record as fatal, same as before.
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await AnalyticsService.instance.initialize();
  } catch (e, stack) {
    debugPrint('Firebase init error: $e\n$stack');
    // Continue boot — Firebase failure must never block the app.
  }

  // ── AdMob SDK init (Ship 3) ─────────────────────────────────────────────
  // Initializes the underlying Mobile Ads SDK only. AdService.initialize()
  // is called LATER (after Hive open) because guard-state stamping needs
  // the `settings` box. Wrapped in try/catch so SDK init failure never
  // blocks app boot.
  try {
    await MobileAds.instance.initialize();
  } catch (e, stack) {
    debugPrint('AdMob SDK init error: $e\n$stack');
  }

  late SettingsProvider settingsProvider;
  late TrackingProvider trackingProvider;
  late DzikirProvider   dzikirProvider;
  late QuranProvider    quranProvider;
  late MurottalProvider murottalProvider;
  bool onboardingDone = false;

  try {
    await Workmanager().initialize(_workmanagerDispatcher);
    await Workmanager().registerPeriodicTask(
      _kWidgetTaskName,
      _kWidgetTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:        Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    await Hive.initFlutter();
    Hive.registerAdapter(IbadahTrackingAdapter());

    await initializeDateFormatting('id_ID');
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('ar');

    await NotificationService.initialize();
    await PermissionService.getManufacturer();

    settingsProvider = SettingsProvider();
    await settingsProvider.initialize();

    // ── IAP init (Ship 4: scaffolding) ─────────────────────────────────
    // Fire-and-forget so Play Store queryProductDetails network call
    // doesn't block splash screen. Premium state is read from Hive
    // (instant) so app behavior never waits on IAP init.
    // Requires `settings` Hive box to be open — that's done above.
    unawaited(
      IapService.instance.initialize().catchError((Object e, StackTrace s) {
        debugPrint('IapService init error (non-blocking): $e\n$s');
      }),
    );

    // ── AdService init (Bulan 2: stamps install timestamp + preloads) ──
    // Must run AFTER `settings` Hive box is open (settingsProvider.initialize
    // above) so first-launch stamping persists. Fire-and-forget so the
    // network ad fetch doesn't block splash; guards run lazily on each
    // showAdIfAvailable() call so a failed/late init doesn't break logic.
    unawaited(
      AdService.instance.initialize().catchError((Object e, StackTrace s) {
        debugPrint('AdService init error (non-blocking): $e\n$s');
      }),
    );

    onboardingDone =
        Hive.box('settings').get('onboarding_done', defaultValue: false) as bool;

    trackingProvider = TrackingProvider();
    await trackingProvider.initialize();
    trackingProvider.setRamadanMode(settingsProvider.ramadanMode);
    settingsProvider.addListener(() {
      trackingProvider.setRamadanMode(settingsProvider.ramadanMode);
    });

    dzikirProvider = DzikirProvider();
    await dzikirProvider.initialize();

    quranProvider = QuranProvider();
    await quranProvider.initialize();

    await JustAudioBackground.init(
      androidNotificationChannelId: 'studio.frosthoot.prayer_app.murottal',
      androidNotificationChannelName: 'Murottal Al-Quran',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );

    murottalProvider = MurottalProvider();
    await murottalProvider.initialize();
  } catch (e, stack) {
    debugPrint('Init error: $e\n$stack');
    // Fallback: create empty providers so the app can still launch
    settingsProvider  = SettingsProvider();
    trackingProvider  = TrackingProvider();
    dzikirProvider    = DzikirProvider();
    quranProvider     = QuranProvider();
    murottalProvider  = MurottalProvider();
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: trackingProvider),
        ChangeNotifierProvider.value(value: dzikirProvider),
        ChangeNotifierProvider.value(value: quranProvider),
        ChangeNotifierProvider.value(value: murottalProvider),
        ChangeNotifierProvider(create: (_) => PrayerProvider(settingsProvider)),
      ],
      child: PrayerApp(onboardingDone: onboardingDone),
    ),
  );
}

class PrayerApp extends StatefulWidget {
  final bool onboardingDone;
  const PrayerApp({super.key, required this.onboardingDone});

  @override
  State<PrayerApp> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> with WidgetsBindingObserver {
  /// Timestamp of when the app was last backgrounded. Used to skip the
  /// App Open Ad on quick app switches (e.g. user briefly checks Slack
  /// notification then comes back) — annoying to interrupt with an ad.
  DateTime? _backgroundedAt;

  /// Resumes within this window are treated as quick-switch and don't
  /// trigger an ad. Tunes the perceived "intentional re-open" threshold.
  static const Duration _quickSwitchThreshold = Duration(seconds: 30);

  /// Listener registered in initState that fires the cold-start ad once
  /// PrayerProvider.prayerTimes becomes non-empty. Removed after first fire
  /// so subsequent prayer-time recalculations don't re-trigger ads.
  /// Null if cold-start ad has already fired (or onboarding skipped it).
  VoidCallback? _coldStartAdListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Cold-start ad attempt — registered after the first frame so the
    // Provider tree is mounted. Doesn't fire immediately: waits for
    // PrayerProvider.prayerTimes to populate so the prayer-window guard
    // has data to check against. Without this wait, the ad could fire
    // during an actual prayer window because the guard sees empty list.
    //
    // Warm resumes don't need this — didChangeAppLifecycleState runs
    // long after PrayerProvider is initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleColdStartAd();
    });
  }

  /// Either fires the cold-start ad immediately (if prayerTimes already
  /// populated — warm cache case) or registers a one-shot listener that
  /// fires it on the first non-empty prayerTimes update.
  void _scheduleColdStartAd() {
    if (!mounted) return;
    final pp = context.read<PrayerProvider>();

    // Fast path: PrayerProvider already initialized (e.g. via hot-reload
    // or the post-onboarding launch where init happens earlier).
    if (pp.prayerTimes.isNotEmpty) {
      _maybeShowAppOpenAd();
      return;
    }

    // Slow path: wait for first non-empty update. Listener self-removes
    // after firing once. If prayerTimes never populates (no GPS, offline,
    // user denies location forever), the ad never shows — which is the
    // desired safe behavior: don't show ads when we can't verify timing.
    _coldStartAdListener = () {
      if (pp.prayerTimes.isNotEmpty && _coldStartAdListener != null) {
        pp.removeListener(_coldStartAdListener!);
        _coldStartAdListener = null;
        _maybeShowAppOpenAd();
      }
    };
    pp.addListener(_coldStartAdListener!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_coldStartAdListener != null && mounted) {
      try {
        context.read<PrayerProvider>().removeListener(_coldStartAdListener!);
      } catch (_) {
        // Provider tree may already be unmounted during shutdown — ignore.
      }
      _coldStartAdListener = null;
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundedAt != null) {
        final awayDuration = DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        if (awayDuration < _quickSwitchThreshold) {
          debugPrint(
            '[AdService] Resume after only ${awayDuration.inSeconds}s '
            '— skipping ad (quick-switch threshold)',
          );
          return;
        }
      }
      _maybeShowAppOpenAd();
    }
  }

  /// Reads current prayer times + premium state and asks AdService to
  /// show the App Open Ad. AdService runs all guards internally; this
  /// method is just the wiring.
  void _maybeShowAppOpenAd() {
    if (!mounted) return;
    final prayerProvider = context.read<PrayerProvider>();
    final upcomingTimes =
        prayerProvider.prayerTimes.map((p) => p.time).toList();

    AdService.instance.showAdIfAvailable(
      prayerTimesToday: upcomingTimes,
      isPremium: IapService.instance.isPremium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings  = context.watch<SettingsProvider>();
    final themeMode = settings.themeMode;
    final lang      = settings.language;
    final isRtl     = lang == AppLanguage.ar;

    return MaterialApp(
      title: 'Waktu Shalat',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [AnalyticsService.instance.observer],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      locale: Locale(lang.name),
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: widget.onboardingDone
          ? const MainScreen()
          : const OnboardingScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      const darkScheme = ColorScheme.dark(
        primary: Color(0xFFD4A057),
        onPrimary: Color(0xFF1A1C2E),
        primaryContainer: Color(0xFF2E3150),
        secondary: Color(0xFFD4A057),
        surface: Color(0xFF252840),
        onSurface: Color(0xFFE8E8F0),
        onSurfaceVariant: Color(0xFFB0B3C6),
        outline: Color(0xFF2E3150),
      );
      final base = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF1A1C2E),
      );
      return base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      );
    }

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFFCE7E50),
      scaffoldBackgroundColor: const Color(0xFFFBF6F0),
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    );
  }
}
