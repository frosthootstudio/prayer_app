import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/ad_service.dart';
import '../services/iap_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';

/// Read-only diagnostic dump for support tickets.
///
/// Reachable only via Settings → About → tap Version row 5 times.
/// Intentionally not localized: this screen is for support / Babah, not end
/// users; mixed-language strings would obscure the data.
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _collectAll();
  }

  Future<Map<String, dynamic>> _collectAll() async {
    final pkg = await PackageInfo.fromPlatform();
    final manufacturer = await PermissionService.getManufacturer();
    final hasNotif = await PermissionService.hasNotification();
    final hasBattery = await PermissionService.hasBatteryOptimization();
    final hasExactAlarm = await PermissionService.hasExactAlarm();

    final settingsBox = Hive.isBoxOpen('settings') ? Hive.box('settings') : null;
    final qiblaFailCount = settingsBox?.get('qibla_sensor_fail_count', defaultValue: 0) ?? 0;
    final qiblaBlocked = settingsBox?.get('qibla_sensor_blocked', defaultValue: false) ?? false;

    final iap = IapService.instance;
    final ad = AdService.instance.debugSnapshot();

    return {
      'app': {
        'package': pkg.packageName,
        'version': '${pkg.version}+${pkg.buildNumber}',
      },
      'device': {
        'manufacturer': manufacturer,
        'isXiaomi': PermissionService.isXiaomiDevice,
      },
      'permissions': {
        'notification': hasNotif,
        'batteryOptimization': hasBattery,
        'exactAlarm': hasExactAlarm,
      },
      'qibla': {
        'failCount': qiblaFailCount,
        'blocked': qiblaBlocked,
      },
      'iap': {
        'isPremium': iap.isPremium,
        'productsReady': iap.productsReadyNotifier.value,
        'lastError': iap.lastErrorMessage.value ?? '(none)',
        'purchaseStatus': iap.purchaseStatus.value.toString(),
      },
      'ad': ad,
      'notifChannel': NotificationService.lastInitError ?? '(initialized OK)',
    };
  }

  void _copyAll(Map<String, dynamic> data) {
    final buf = StringBuffer();
    void writeMap(String prefix, Map m) {
      m.forEach((k, v) {
        if (v is Map) {
          writeMap('$prefix$k.', v);
        } else {
          buf.writeln('$prefix$k: $v');
        }
      });
    }
    writeMap('', data);
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() => _dataFuture = _collectAll()),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...data.entries.map((e) => _Section(title: e.key, value: e.value)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _copyAll(data),
                icon: const Icon(Icons.copy),
                label: const Text('Copy all to clipboard'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final dynamic value;
  const _Section({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.appTextFaded,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          if (value is Map)
            ..._renderMap(context, value)
          else
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'monospace',
                color: context.appTextPrimary,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _renderMap(BuildContext context, Map m) {
    return m.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                e.key.toString(),
                style: TextStyle(
                  fontSize: 13,
                  color: context.appTextSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${e.value}',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: context.appTextPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
