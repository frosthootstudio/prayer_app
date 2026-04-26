import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'services/notification_service.dart';
import 'services/permission_service.dart';

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

class _PrayerAppState extends State<PrayerApp> {
  @override
  void initState() {
    super.initState();
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
