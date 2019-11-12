import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';


class SystemControl {
  static SystemControl _playSound;

  static AudioCache _audioCache = AudioCache();

  factory SystemControl() => _playSound ??= SystemControl._();

  SystemControl._();

  AudioPlayer _audioPlayer;

  playSound(String mp3) async {
          stopSound();
    _audioPlayer = await _audioCache.play(mp3, mode: PlayerMode.LOW_LATENCY);
    
  }

  stopSound() {
    if (_audioPlayer != null) {
      _audioPlayer.stop();
    }
  }

  doVibrate(int duration) async {
    
    bool hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      bool hasAmplitude = await Vibration.hasAmplitudeControl();
      if (hasAmplitude) {
        await Vibration.cancel();
        Vibration.vibrate(duration: duration, amplitude: 128);
      } else {
        await Vibration.cancel();
        Vibration.vibrate(duration: duration);
      }
    }
  }

  alwaysScreenLit() async{
      await Wakelock.enable();
  }
}
