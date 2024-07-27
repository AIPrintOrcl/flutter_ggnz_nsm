import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/utils/getx_controller.dart';
import 'package:hexcolor/hexcolor.dart';

//
// incubator_page.dart => Watch(isDialog: false) : 게임 메인 화면의 상단 중간에 있는 시계
// dispatch_dialog.dart => Watch(isDialog: true,)
class Watch extends StatelessWidget {
  final isDialog;
  const Watch({Key? key, required this.isDialog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isDialog ? buildTimeDialog() : buildTime(),
    );
  }

  Widget buildTime() {
    final watchController = Get.find<WatchController>();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return Obx(() {
      final hours = twoDigits(watchController.duration.inHours);
      final minutes =
          twoDigits(watchController.duration.inMinutes.remainder(60));
      final seconds =
          twoDigits(watchController.duration.inSeconds.remainder(60));

      return Container(
        width: 100,
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTimeCard(
                time: hours,
              ),
              Container(
                child: Text(
                  ':',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              buildTimeCard(
                time: minutes,
              ),
              Container(
                child: Text(
                  ':',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              buildTimeCard(
                time: seconds,
              ),
            ]),
      );
    });
  }

  Widget buildTimeCard({required String time}) => Container(
        child: Text(
          time,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
        ),
      );

  Widget buildTimeDialog() {
    final watchController = Get.find<WatchController>();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return Obx(() {
      final hours = twoDigits(watchController.duration.inHours);
      final minutes =
          twoDigits(watchController.duration.inMinutes.remainder(60));
      final seconds =
          twoDigits(watchController.duration.inSeconds.remainder(60));

      return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTimeDialogCard(
              time: hours,
            ),
            DefaultTextStyle(
              style: TextStyle(color: HexColor("#555D42"), fontSize: 15),
              child: Text(
                ':',
              ),
            ),
            buildTimeDialogCard(
              time: minutes,
            ),
            DefaultTextStyle(
              style: TextStyle(color: HexColor("#555D42"), fontSize: 15),
              child: Text(
                ':',
              ),
            ),
            buildTimeDialogCard(
              time: seconds,
            ),
          ]);
    });
  }

  Widget buildTimeDialogCard({required String time}) => Container(
        child: DefaultTextStyle(
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade400,
              fontSize: 15),
          child: Text(
            time,
          ),
        ),
      );
}

class WatchController extends GetxController {
  final _duration = Duration().obs;
  Duration get duration => _duration.value;

  void add({required int seconds}) {
    _duration.value = Duration(seconds: seconds);
  }

  void startTimer() {
    getx.environmentTime.listen((value) {
      add(seconds: value.toInt());
    });
  }

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }
}
