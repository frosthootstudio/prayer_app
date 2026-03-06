import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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

  // ── Current playback state ────────────────────────────────────────────────

  int?     _surah;
  int?     _ayah;
  bool     _isPlaying = false;
  bool     _isLoading = false;
  Duration _position  = Duration.zero;
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
  Duration       get position      => _position;
  Duration       get duration      => _duration;
  Reciter        get reciter       => _reciter;
  MurottalRepeat get repeatMode    => _repeatMode;
  double         get speed         => _speed;

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
      _position = pos;
      notifyListeners();
    });

    // Duration (reports duration of current ayah)
    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  // ── Playlist builder ──────────────────────────────────────────────────────

  List<AudioSource> _buildSources(int surah) {
    final count     = quran.getVerseCount(surah);
    final surahName = quran.getSurahName(surah);
    return List.generate(count, (i) {
      final ayah = i + 1;
      return AudioSource.uri(
        Uri.parse(_reciter.audioUrl(surah, ayah)),
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
    _position  = Duration.zero;
    _duration  = Duration.zero;
    notifyListeners();

    try {
      final sources = _buildSources(surah);
      await _player.stop();
      await _player.setAudioSources(sources, initialIndex: ayah - 1);
      await _player.setSpeed(_speed);
      _applyLoopMode();
      await _player.play();
    } catch (_) {
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
    final newPos = _position - const Duration(seconds: 10);
    await _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> forward() async {
    final newPos = _position + const Duration(seconds: 10);
    await _player.seek(newPos > _duration ? _duration : newPos);
  }

  Future<void> stop() async {
    await _player.stop();
    _surah     = null;
    _ayah      = null;
    _isPlaying = false;
    _position  = Duration.zero;
    _duration  = Duration.zero;
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<void> setReciter(Reciter r) async {
    _reciter = r;
    await _box.put(_kReciter, r.index);
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
    _player.dispose();
    super.dispose();
  }
}
