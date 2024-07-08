import 'package:get/get.dart';
import 'package:ggnz/services/service_app_init.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MainPageLoading extends StatelessWidget {
  const MainPageLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(url: 'assets/sound/ggnz_logo.mp3');
    final mainLoadingController = Get.find<ServiceAppInit>();

    return Scaffold(
        body: /*Obx(() {
          return */Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/ggnz_logo.gif'), fit: BoxFit.cover),
                    color: Colors.white70,
                  ),
                )
              ),
              /*LinearPercentIndicator(
                alignment: MainAxisAlignment.center,
                width: MediaQuery.of(context).size.width * 0.9 ,
                animation: true,
                animationDuration: 1200,
                lineHeight: 30.0,
                percent: mainLoadingController.current_image.value / mainLoadingController.total_image.value,
                center: Text('downloading resources (${mainLoadingController.current_image.value}/${mainLoadingController.total_image.value})'),
                barRadius: Radius.circular(16.0),
                progressColor: Colors.lightGreen,
              )*/
            ],
          )
        /*})*/
    );
  }
}
