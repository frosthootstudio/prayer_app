import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;

// ── Reciter ───────────────────────────────────────────────────────────────────

enum Reciter {
  alafasy("Mishary Alafasy",          'Alafasy_128kbps'),
  sudais("Abdul Rahman Al-Sudais",    'Abdurrahmaan_As-Sudais_192kbps'),
  ghamdi("Saad Al-Ghamdi",            'Saad_Al-Ghamdi_128kbps'),
  muaiqly("Maher Al-Muaiqly",         'Maher_AlMuaiqly_128kbps'),
  shuraim("Sa\u2019ud Al-Shuraim",    'Shuraim_128kbps');

  const Reciter(this.displayName, this._folder);

  final String displayName;
  final String _folder;

  String audioUrl(int surah, int ayah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$_folder/$s$a.mp3';
  }
}

// ── Repeat mode ───────────────────────────────────────────────────────────────

enum MurottalRepeat { off, ayah, surah }

// ── Provider ──────────────────────────────────────────────────────────────────

class MurottalProvider extends ChangeNotifier {
  static const _kReciter = 'm_reciter';

  late Box _box;

  // ── Offline download cache state ──────────────────────────────────────────
  Directory? _cacheBaseDir;
  final Set<int> _downloadedSurahs = {};
  final Set<int> _downloadingSurahs = {};
  final Map<int, double> _downloadProgress = {};

  // ── Current playback state ────────────────────────────────────────────────

  int?     _surah;
  int?     _ayah;
  bool     _isPlaying = false;
  bool     _isLoading = false;
  /// Playback position, exposed as its own notifier so the seek slider
  /// can listen at stream frequency (~5Hz) without rebuilding every
  /// MurottalProvider watcher via notifyListeners.
  final ValueNotifier<Duration> positionNotifier =
      ValueNotifier(Duration.zero);
  Duration _duration  = Duration.zero;

  Reciter        _reciter    = Reciter.alafasy;
  MurottalRepeat _repeatMode = MurottalRepeat.off;
  double         _speed      = 1.0;

  final AudioPlayer _player = AudioPlayer();

  // ── Getters ───────────────────────────────────────────────────────────────

  int?           get currentSurah  => _surah;
  int?           get currentAyah   => _ayah;
  bool           get isPlaying     => _isPlaying;
  bool           get isLoading     => _isLoading;
  Duration       get position      => positionNotifier.value;
  Duration       get duration      => _duration;
  Reciter        get reciter       => _reciter;
  MurottalRepeat get repeatMode    => _repeatMode;
  double         get speed         => _speed;

  bool isSurahDownloaded(int surah) => _downloadedSurahs.contains(surah);
  bool isDownloading(int surah)     => _downloadingSurahs.contains(surah);
  double getDownloadProgress(int surah) => _downloadProgress[surah] ?? 0.0;

  bool isPlayingAyah(int surah, int ayah) =>
      _surah == surah && _ayah == ayah && (_isPlaying || _isLoading);

  String get currentSurahName =>
      _surah != null ? quran.getSurahName(_surah!) : '';

  int get currentAyahCount =>
      _surah != null ? quran.getVerseCount(_surah!) : 0;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _box = await Hive.openBox('murottal_prefs');
    final ri = _box.get(_kReciter, defaultValue: 0) as int;
    _reciter = Reciter.values[ri.clamp(0, Reciter.values.length - 1)];

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _cacheBaseDir = Directory('${appDocDir.path}/murottal');
      await _refreshDownloadedSurahs();
    } catch (e) {
      debugPrint('[Murottal] cacheBaseDir init error: $e');
    }

    // Track which ayah is playing via playlist index
    _player.currentIndexStream.listen((index) {
      if (index != null && _surah != null) {
        _ayah = index + 1;
        notifyListeners();
      }
    });

    // Player state
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
                   state.processingState == ProcessingState.buffering;
      notifyListeners();
    });

    // Position (resets to 0 at start of each ayah in playlist)
    _player.positionStream.listen((pos) {
      positionNotifier.value = pos;
    });

    // Duration (reports duration of current ayah)
    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  // ── Offline storage sync & actions ────────────────────────────────────────

  Future<void> _refreshDownloadedSurahs() async {
    _downloadedSurahs.clear();
    if (_cacheBaseDir != null && _cacheBaseDir!.existsSync()) {
      final reciterDir = Directory('${_cacheBaseDir!.path}/${_reciter.name}');
      if (reciterDir.existsSync()) {
        try {
          for (final entity in reciterDir.listSync()) {
            if (entity is Directory) {
              final segments = entity.uri.pathSegments.where((s) => s.isNotEmpty);
              if (segments.isNotEmpty) {
                final surahNum = int.tryParse(segments.last);
                if (surahNum != null) {
                  final count = quran.getVerseCount(surahNum);
                  final mp3s = entity
                      .listSync()
                      .whereType<File>()
                      .where((f) => f.path.endsWith('.mp3') && f.lengthSync() > 0);
                  if (mp3s.length >= count) {
                    _downloadedSurahs.add(surahNum);
                  }
                }
              }
            }
          }
        } catch (e) {
          debugPrint('[Murottal] _refreshDownloadedSurahs error: $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> downloadSurah(int surah) async {
    if (_downloadingSurahs.contains(surah) || _cacheBaseDir == null) return;
    _downloadingSurahs.add(surah);
    _downloadProgress[surah] = 0.0;
    notifyListeners();

    try {
      final surahDir = Directory('${_cacheBaseDir!.path}/${_reciter.name}/$surah');
      if (!surahDir.existsSync()) {
        await surahDir.create(recursive: true);
      }
      final count = quran.getVerseCount(surah);
      for (int ayah = 1; ayah <= count; ayah++) {
        final file = File('${surahDir.path}/$ayah.mp3');
        if (!file.existsSync() || file.lengthSync() == 0) {
          final url = _reciter.audioUrl(surah, ayah);
          final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
          if (res.statusCode == 200) {
            await file.writeAsBytes(res.bodyBytes);
          }
        }
        _downloadProgress[surah] = ayah / count;
        notifyListeners();
      }
      _downloadedSurahs.add(surah);
    } catch (e) {
      debugPrint('[Murottal] downloadSurah($surah) error: $e');
    } finally {
      _downloadingSurahs.remove(surah);
      _downloadProgress.remove(surah);
      notifyListeners();
    }
  }

  Future<void> deleteDownloadedSurah(int surah) async {
    if (_cacheBaseDir == null) return;
    try {
      final surahDir = Directory('${_cacheBaseDir!.path}/${_reciter.name}/$surah');
      if (surahDir.existsSync()) {
        await surahDir.delete(recursive: true);
      }
      _downloadedSurahs.remove(surah);
      notifyListeners();
    } catch (e) {
      debugPrint('[Murottal] deleteDownloadedSurah error: $e');
    }
  }

  // ── Playlist builder ──────────────────────────────────────────────────────

  List<AudioSource> _buildSources(int surah) {
    final count     = quran.getVerseCount(surah);
    final surahName = quran.getSurahName(surah);
    final surahDir  = _cacheBaseDir != null
        ? Directory('${_cacheBaseDir!.path}/${_reciter.name}/$surah')
        : null;

    return List.generate(count, (i) {
      final ayah = i + 1;
      final localFile = surahDir != null ? File('${surahDir.path}/$ayah.mp3') : null;
      final isLocal = localFile != null && localFile.existsSync() && localFile.lengthSync() > 0;

      return AudioSource.uri(
        isLocal ? Uri.file(localFile.path) : Uri.parse(_reciter.audioUrl(surah, ayah)),
        tag: MediaItem(
          id:     '${surah}_$ayah',
          album:  _reciter.displayName,
          title:  '$surahName – Ayah $ayah',
          artist: _reciter.displayName,
        ),
      );
    });
  }

  void _applyLoopMode() {
    switch (_repeatMode) {
      case MurottalRepeat.ayah:
        _player.setLoopMode(LoopMode.one);
      case MurottalRepeat.surah:
        _player.setLoopMode(LoopMode.all);
      case MurottalRepeat.off:
        _player.setLoopMode(LoopMode.off);
    }
  }

  // ── Playback controls ─────────────────────────────────────────────────────

  Future<void> playAyah(int surah, int ayah) async {
    // Toggle pause/play when tapping the currently active ayah
    if (_surah == surah && _ayah == ayah) {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    // Same surah already loaded — just seek to target ayah
    if (_surah == surah) {
      await _player.seek(Duration.zero, index: ayah - 1);
      if (!_isPlaying) await _player.play();
      return;
    }

    // Different surah — build a fresh playlist
    _surah     = surah;
    _ayah      = ayah;
    _isLoading = true;
    positionNotifier.value = Duration.zero;
    _duration  = Duration.zero;
    notifyListeners();

    try {
      final sources = _buildSources(surah);
      await _player.stop();
      await _player.setAudioSources(sources, initialIndex: ayah - 1);
      await _player.setSpeed(_speed);
      _applyLoopMode();
      await _player.play();
    } catch (e) {
      debugPrint('[Murottal] playAyah($surah:$ayah) load failed: $e');
      // Reset surah/ayah so a retry tap rebuilds the playlist instead of
      // hitting the same-surah fast path and silently seeking into a
      // playlist that never loaded.
      _surah     = null;
      _ayah      = null;
      _isLoading = false;
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> nextAyah() => _player.seekToNext();

  Future<void> prevAyah() => _player.seekToPrevious();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> rewind() async {
    final newPos = positionNotifier.value - const Duration(seconds: 10);
    await _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> forward() async {
    final newPos = positionNotifier.value + const Duration(seconds: 10);
    await _player.seek(newPos > _duration ? _duration : newPos);
  }

  Future<void> stop() async {
    await _player.stop();
    _surah     = null;
    _ayah      = null;
    _isPlaying = false;
    positionNotifier.value = Duration.zero;
    _duration  = Duration.zero;
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<void> setReciter(Reciter r) async {
    _reciter = r;
    await _box.put(_kReciter, r.index);
    await _refreshDownloadedSurahs();
    notifyListeners();

    if (_surah != null && _ayah != null) {
      final targetAyah = _ayah!;
      final wasPlaying = _isPlaying;
      await _player.stop();
      final sources = _buildSources(_surah!);
      await _player.setAudioSources(sources, initialIndex: targetAyah - 1);
      await _player.setSpeed(_speed);
      _applyLoopMode();
      if (wasPlaying) await _player.play();
    }
  }

  void setMurottalRepeat(MurottalRepeat mode) {
    _repeatMode = mode;
    _applyLoopMode();
    notifyListeners();
  }

  Future<void> setSpeed(double s) async {
    _speed = s;
    await _player.setSpeed(s);
    notifyListeners();
  }

  // ── Surah navigation ──────────────────────────────────────────────────────

  Future<void> playSurahFromStart(int surah) async {
    await playAyah(surah, 1);
  }

  @override
  void dispose() {
    positionNotifier.dispose();
    _player.dispose();
    super.dispose();
  }
}
