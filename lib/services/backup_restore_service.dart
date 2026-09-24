import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/prayer_tracking_model.dart';
import '../providers/quran_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tracking_provider.dart';

class BackupRestoreService {
  BackupRestoreService._();

  /// Exports local user data (Ibadah Tracking, Quran Bookmarks, Preferences, Settings)
  /// to a JSON file and opens the system Share sheet.
  static Future<bool> exportBackup(BuildContext context) async {
    try {
      // 1. Ibadah tracking
      final trackingBox = Hive.box<IbadahTracking>('ibadah_tracking');
      final trackingMap = <String, dynamic>{};
      for (final key in trackingBox.keys) {
        final item = trackingBox.get(key);
        if (item != null) {
          trackingMap[key.toString()] = {
            'date': item.date,
            'taskKey': item.taskKey,
            'isDone': item.isDone,
            'timestamp': item.timestamp?.toIso8601String(),
          };
        }
      }

      // 2. Quran bookmarks
      final bookmarksBox = Hive.box('quran_bookmarks');
      final bookmarksList = bookmarksBox.values.cast<String>().toList();

      // 3. Quran prefs
      final quranPrefsBox = Hive.box('quran_prefs');
      final quranPrefsMap = <String, dynamic>{};
      for (final key in quranPrefsBox.keys) {
        quranPrefsMap[key.toString()] = quranPrefsBox.get(key);
      }

      // 4. Dzikir favorites
      final dzikirBox = Hive.isBoxOpen('dzikir_favorites')
          ? Hive.box('dzikir_favorites')
          : await Hive.openBox('dzikir_favorites');
      final dzikirList = dzikirBox.values.toList();

      // 5. App settings
      final settingsBox = Hive.box('settings');
      final settingsMap = <String, dynamic>{};
      for (final key in settingsBox.keys) {
        final val = settingsBox.get(key);
        if (val is String || val is num || val is bool) {
          settingsMap[key.toString()] = val;
        }
      }

      final payload = {
        'app': 'Waktu Shalat',
        'packageId': 'studio.frosthoot.prayer_app',
        'schemaVersion': 1,
        'appVersion': '1.7.4+43',
        'exportDate': DateTime.now().toIso8601String(),
        'summary': {
          'trackingCount': trackingMap.length,
          'bookmarksCount': bookmarksList.length,
          'dzikirFavoritesCount': dzikirList.length,
        },
        'data': {
          'ibadahTracking': trackingMap,
          'quranBookmarks': bookmarksList,
          'quranPrefs': quranPrefsMap,
          'dzikirFavorites': dzikirList,
          'settings': settingsMap,
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${tempDir.path}/waktu_shalat_backup_$dateStr.json');
      await file.writeAsString(jsonString);

      if (!context.mounted) return false;

      final sp = context.read<SettingsProvider>();
      final isEn = sp.isEnglish;

      final shareText = isEn
          ? 'Waktu Shalat Backup File - ${DateFormat('dd MMM yyyy').format(DateTime.now())}'
          : 'Cadangan Data Waktu Shalat - ${DateFormat('dd MMM yyyy').format(DateTime.now())}';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json', name: 'waktu_shalat_backup_$dateStr.json')],
          text: shareText,
          subject: 'Waktu Shalat Backup',
        ),
      );

      return true;
    } catch (e) {
      debugPrint('[BackupRestoreService] export error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor data: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Imports and restores user data from a picked JSON backup file.
  static Future<bool> importBackup(BuildContext context) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return false;
      }

      final path = files.first.path;
      if (path == null) return false;

      final file = File(path);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      final dynamic decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic> || decoded['data'] is! Map<String, dynamic>) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format file cadangan tidak valid.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return false;
      }

      final data = decoded['data'] as Map<String, dynamic>;
      final trackingJson = data['ibadahTracking'] as Map<String, dynamic>? ?? {};
      final bookmarksJson = data['quranBookmarks'] as List? ?? [];
      final settingsJson = data['settings'] as Map<String, dynamic>? ?? {};

      if (!context.mounted) return false;

      final sp = context.read<SettingsProvider>();
      final isEn = sp.isEnglish;

      // Show confirmation dialog before applying
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEn ? 'Restore Backup Data?' : 'Pulihkan Data Cadangan?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn
                    ? 'Found in backup file:'
                    : 'Data yang ditemukan dalam file cadangan:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('• ${trackingJson.length} ${isEn ? 'tracking logs' : 'catatan ibadah'}'),
              Text('• ${bookmarksJson.length} ${isEn ? 'Quran bookmarks' : 'bookmark Al-Qur\'an'}'),
              if (settingsJson.isNotEmpty)
                Text('• ${isEn ? 'App settings & preferences' : 'Pengaturan & preferensi aplikasi'}'),
              const SizedBox(height: 14),
              Text(
                isEn
                    ? 'Existing records will be merged and updated. Continue?'
                    : 'Data yang ada akan digabungkan dan diperbarui. Lanjutkan?',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isEn ? 'Cancel' : 'Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A057),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(isEn ? 'Restore' : 'Pulihkan'),
            ),
          ],
        ),
      );

      if (confirmed != true) return false;

      // 1. Restore Ibadah tracking
      final trackingBox = Hive.box<IbadahTracking>('ibadah_tracking');
      for (final entry in trackingJson.entries) {
        if (entry.value is Map<String, dynamic>) {
          final m = entry.value as Map<String, dynamic>;
          final item = IbadahTracking(
            date: m['date'] as String? ?? '',
            taskKey: m['taskKey'] as String? ?? '',
            isDone: m['isDone'] as bool? ?? false,
            timestamp: m['timestamp'] != null
                ? DateTime.tryParse(m['timestamp'] as String)
                : null,
          );
          if (item.date.isNotEmpty && item.taskKey.isNotEmpty) {
            await trackingBox.put(entry.key, item);
          }
        }
      }

      // 2. Restore Quran bookmarks
      final bookmarksBox = Hive.box('quran_bookmarks');
      for (final b in bookmarksJson) {
        final key = b.toString();
        if (key.isNotEmpty) {
          await bookmarksBox.put(key, key);
        }
      }

      // 3. Restore Quran prefs
      if (data['quranPrefs'] is Map<String, dynamic>) {
        final quranPrefsBox = Hive.box('quran_prefs');
        final qPrefs = data['quranPrefs'] as Map<String, dynamic>;
        for (final e in qPrefs.entries) {
          await quranPrefsBox.put(e.key, e.value);
        }
      }

      // 4. Restore Dzikir favorites
      if (data['dzikirFavorites'] is List) {
        final dzikirBox = Hive.isBoxOpen('dzikir_favorites')
            ? Hive.box('dzikir_favorites')
            : await Hive.openBox('dzikir_favorites');
        final dList = data['dzikirFavorites'] as List;
        for (final item in dList) {
          if (!dzikirBox.values.contains(item)) {
            await dzikirBox.add(item);
          }
        }
      }

      // 5. Restore Settings
      if (settingsJson.isNotEmpty) {
        final settingsBox = Hive.box('settings');
        for (final e in settingsJson.entries) {
          await settingsBox.put(e.key, e.value);
        }
      }

      if (!context.mounted) return true;

      // Reload providers
      context.read<TrackingProvider>().reload();
      context.read<QuranProvider>().reload();
      context.read<SettingsProvider>().reload();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'Data restored successfully! (${trackingJson.length} tracking, ${bookmarksJson.length} bookmarks)'
                : 'Data berhasil dipulihkan! (${trackingJson.length} catatan, ${bookmarksJson.length} bookmark)',
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return true;
    } catch (e) {
      debugPrint('[BackupRestoreService] import error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulihkan data: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }
}
