import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/main_page.dart';
import 'package:ggnz/presentation/pages/password/password_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  static LoginController instance = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;

  GoogleSignIn _googleSignIn = GoogleSignIn(); /* 로그인 여부 */

  late Rx<User?> _user; /* 사용자 정보 */
  User? get getUser => _user.value;

  // 컨트롤러가 생성될 때 호출되며, 주로 초기화 작업
  @override
  void onInit() {
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());

    super.onInit();
  }

  // 모든 초기화 작업이 완료되고 UI가 렌더링된 후에 호출
  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    print("현재 로그인 이메일 : " + _user.value!.email.toString());
    ever(_user, _initialScreen); /* 로그인 여부에 따라 홈 or 로그인으로 화면 전환 */
  }

  // 유저가 null이면 로그인 창, 아니면 홈 페이지로 이동
  _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => MainPage());
    } else {
      Get.offAll(() => PasswordPage());
    }
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); /* 로그인 */
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(credential);
  }

  void signOut() async {
    await _googleSignIn.disconnect(); /* 구글 인증 연결 끊기 */
    await auth.signOut(); /* 로그아웃 */

    Get.offAll(() => MainPage());
  }
}