import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:get/get.dart';
import 'package:ggnz/utils/getx_controller.dart';

class AudioController extends GetxController {
  final _audioPlayer = AssetsAudioPlayer();

  Future<void> pauseAudioPlayer() async {
    await _audioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _audioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer() async {
    await _audioPlayer.setVolume(getx.volume.value);
  }

  Future<void> openAudioPlayer({required String url, bool? isLoop}) async {
    await _audioPlayer.open(Audio(url),
        loopMode: isLoop != null ? LoopMode.playlist : LoopMode.none,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }
}

class BgmController extends GetxController {
  final Rx<String> _backgroundStateBgm = getx.environmentLevel.value < 240.0
      ? 'assets/sound/bgm_environment_bad.mp3'.obs
      : getx.environmentLevel.value < 480.0
          ? 'assets/sound/bgm_environment_normal.mp3'.obs
          : 'assets/sound/bgm_environment_good.mp3'.obs;
  String get backgroundStateBgm => _backgroundStateBgm.value;

  final _bgmAudioPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer get bgmAudioPlayer => _bgmAudioPlayer;

  Future<void> bgmOpenAudioPlayer({required String url}) async {
    await _bgmAudioPlayer.open(Audio(url),
        loopMode: LoopMode.playlist,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }

  Future<void> pauseAudioPlayer() async {
    await _bgmAudioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _bgmAudioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer() async {
    await _bgmAudioPlayer.setVolume(getx.volume.value);
  }

  Future<void> stopAndPlayBgm({
    required int playTime,
  }) async {
    await bgmAudioPlayer.pause();

    Future.delayed(Duration(seconds: playTime),
        () => bgmOpenAudioPlayer(url: backgroundStateBgm));
  }

  @override
  void onInit() {
    getx.environmentLevel.listen((environmentLevel) {
      environmentLevel < 240.0
          ? _backgroundStateBgm.value = 'assets/sound/bgm_environment_bad.mp3'
          : environmentLevel < 480.0
              ? _backgroundStateBgm.value =
                  'assets/sound/bgm_environment_normal.mp3'
              : _backgroundStateBgm.value =
                  'assets/sound/bgm_environment_good.mp3';
    });
    super.onInit();
  }
}

class TransitionAudioController extends GetxController {
  final _transitionAudioPlayer = AssetsAudioPlayer();

  Future<void> pauseAudioPlayer() async {
    await _transitionAudioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _transitionAudioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer() async {
    await _transitionAudioPlayer.setVolume(getx.volume.value);
  }

  Future<void> openAudioPlayer({required String url, bool? isLoop}) async {
    await _transitionAudioPlayer.open(Audio(url),
        loopMode: isLoop != null ? LoopMode.playlist : LoopMode.none,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }
}

class MarimoAudioController extends GetxController {
  final _marimoAudioPlayer = AssetsAudioPlayer();

  Future<void> pauseAudioPlayer() async {
    await _marimoAudioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _marimoAudioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer() async {
    await _marimoAudioPlayer.setVolume(getx.volume.value);
  }

  Future<void> openAudioPlayer({required String url, bool? isLoop}) async {
    await _marimoAudioPlayer.open(Audio(url),
        loopMode: isLoop != null ? LoopMode.playlist : LoopMode.none,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }
}

class EmotionAudioController extends GetxController {
  final _emotionAudioPlayer = AssetsAudioPlayer();

  Future<void> pauseAudioPlayer() async {
    await _emotionAudioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _emotionAudioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer() async {
    await _emotionAudioPlayer.setVolume(getx.volume.value);
  }

  Future<void> openAudioPlayer({required String url, bool? isLoop}) async {
    await _emotionAudioPlayer.open(Audio(url),
        loopMode: isLoop != null ? LoopMode.playlist : LoopMode.none,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }
}

class EggStateAudioController extends GetxController {
  final _eggAwakeAudioPlayer = AssetsAudioPlayer();

  Future<void> pauseAudioPlayer() async {
    await _eggAwakeAudioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _eggAwakeAudioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer({double? localVolume}) async {
    await _eggAwakeAudioPlayer
        .setVolume(localVolume != null ? localVolume : getx.volume.value);
  }

  Future<void> openAudioPlayer({required String url, bool? isLoop}) async {
    await _eggAwakeAudioPlayer.open(Audio(url),
        loopMode: isLoop != null ? LoopMode.playlist : LoopMode.none,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }
}

class EnvironmentChangeAudioController extends GetxController {
  final _environmentChangeAudioPlayer = AssetsAudioPlayer();

  Future<void> pauseAudioPlayer() async {
    await _environmentChangeAudioPlayer.pause();
  }

  Future<void> playAudioPlayer() async {
    await _environmentChangeAudioPlayer.play();
  }

  Future<void> setVolumeAudioPlayer() async {
    await _environmentChangeAudioPlayer.setVolume(getx.volume.value);
  }

  Future<void> openAudioPlayer({required String url, bool? isLoop}) async {
    await _environmentChangeAudioPlayer.open(Audio(url),
        loopMode: isLoop != null ? LoopMode.playlist : LoopMode.none,
        playInBackground: PlayInBackground.disabledRestoreOnForeground,
        volume: getx.volume.value);
  }
}
