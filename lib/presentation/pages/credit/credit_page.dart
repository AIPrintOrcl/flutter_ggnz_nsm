import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/utils/audio_controller.dart';
import 'package:ggnz/utils/launch_controller.dart';

class CreditPage extends StatelessWidget {
  const CreditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();
    audioController.openAudioPlayer(url: 'assets/sound/title.mp3');

    double bigFontSize = 22;
    double smallFontSize = 13;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        title: Text('credit'.tr,
            style: TextStyle(
                fontFamily: 'ONE_Mobile_POP_OTF',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              imageCache.clear();
              Get.back();
            },
            child: const Center(
                child: Icon(Icons.arrow_back_ios, color: Colors.black))),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.grey,
              BlendMode.modulate,
            ),
            fit: BoxFit.cover,
            image: AssetImage('assets/bg2.gif'),
          ),
        ),
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Spacer(
              flex: 2,
            ),
            Text('TADPOLE DIARY',
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: bigFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const SizedBox(
              height: 5,
            ),
            Text('Credit',
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const Spacer(
              flex: 1,
            ),
            Text('GAME DESIGN',
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: bigFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const SizedBox(
              height: 5,
            ),
            Text('neez.n',
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const Spacer(
              flex: 1,
            ),
            Text('GAEGUNEEZ COMMUNITY',
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: bigFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () {
                launchURL('http://ggnz.io/');
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.blue[300]!,
                  width: 1.5,
                ))),
                child: Text('http://ggnz.io/',
                    style: TextStyle(
                      fontFamily: 'ONE_Mobile_POP_OTF',
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[300],
                    )),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Text('DICORD',
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: bigFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () {
                launchURL('https://discord.com/invite/WqcV8QB8sT');
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.blue[300]!,
                  width: 1.5,
                ))),
                child: Text('GAEGUNEEZ',
                    style: TextStyle(
                      fontFamily: 'ONE_Mobile_POP_OTF',
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[300],
                    )),
              ),
            ),
            const Spacer(
              flex: 2,
            ),
          ]),
        ),
      ),
    );
  }
}
