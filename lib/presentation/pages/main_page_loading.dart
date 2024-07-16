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
                  decoration: const BoxDecoration( /* BoxDecoration : 위젯이나 컨테이너의 모양을 꾸밀 때 사용하는 클래스. 여러 속성을 설정하여 배경 이미지나 색상, 테두리 등을 지정 가능 */
                    image: DecorationImage(
                        image: AssetImage('assets/ggnz_logo.gif'), fit: BoxFit.cover),
                    color: Colors.white70,
                  ),
                )
              ),
              /*LinearPercentIndicator( *//* 로딩 중 진행바 : 전체적으로 사용자가 리소스를 다운로드하는 동안 진행 상황을 쉽게 파악  *//*
                alignment: MainAxisAlignment.center,
                width: MediaQuery.of(context).size.width * 0.9 ,
                animation: true,
                animationDuration: 1200,
                lineHeight: 30.0,
                percent: mainLoadingController.current_image.value / mainLoadingController.total_image.value, *//* 진행률은 mainLoadingController의 current_image 값과 total_image 값을 사용하여 계산 *//*
                center: Text('downloading resources (${mainLoadingController.current_image.value}/${mainLoadingController.total_image.value})'), *//* 진행 바의 중앙에 표시할 텍스트를 설정합니다. 현재 다운로드된 리소스 수와 총 리소스 수를 나타내는 텍스트를 표시합니다. *//*
                barRadius: Radius.circular(16.0),
                progressColor: Colors.lightGreen,
              )*/
            ],
          )
        /*})*/
    );
  }
}
