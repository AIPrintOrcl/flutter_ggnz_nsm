import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/getx_controller.dart';

class ButtonSound extends StatelessWidget {
  const ButtonSound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSoundController = Get.find<ButtonSoundController>();
    return Obx(() {
      return GestureDetector(
        onTap: () {
          buttonSoundController.setIsSoundOn();
          if (buttonSoundController.isSoundOn) {
            buttonSoundController.playSound();
          }

          if (!buttonSoundController.isSoundOn) {
            buttonSoundController.pauseSound();
          }
        },
        child: Stack(
          children: [
            // 소리 킴, 끔 이미지
            Opacity( /// Opacity : 자식 위젯의 투명도를 조절. 1.0 : 완전 투명. 0.0 : 완전 불투명
                opacity: buttonSoundController.isSoundOn ? 1 : 0,
                child: Image.asset("assets/sound_on.png", width: 45)), /* 소리 킴 이미지 */
            Opacity(
                opacity: buttonSoundController.isSoundOn ? 0 : 1,
                child: Image.asset("assets/sound_off.png", width: 45)), /* 소리 끔 이미지*/
          ],
        ),
      );
    });
  }
}

class ButtonSoundController extends GetxController {
  final _isSoundOn = true.obs;
  bool get isSoundOn => _isSoundOn.value;
  void setIsSoundOn() {
    _isSoundOn.value = !_isSoundOn.value;
  }

  final bgmController = Get.find<BgmController>();
  final audioController = Get.find<AudioController>();
  final transitionAudioController = Get.find<TransitionAudioController>();
  final emotionAudioController = Get.find<EmotionAudioController>();
  final eggStateAudioController = Get.find<EggStateAudioController>();

  void pauseSound() {
    getx.volume.value = 0;
    bgmController.setVolumeAudioPlayer();
    audioController.setVolumeAudioPlayer();
    transitionAudioController.setVolumeAudioPlayer();
    emotionAudioController.setVolumeAudioPlayer();
    eggStateAudioController.setVolumeAudioPlayer();
  }

  void playSound() {
    getx.volume.value = 100;
    bgmController.setVolumeAudioPlayer();
    audioController.setVolumeAudioPlayer();
    transitionAudioController.setVolumeAudioPlayer();
    emotionAudioController.setVolumeAudioPlayer();
    eggStateAudioController.setVolumeAudioPlayer();
  }
}
