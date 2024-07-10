import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ggnz/presentation/pages/password/password_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();

    if(googleUser == null) return '구글 연동에 실패했습니다.'; /* 구글 로그인 실패 시 반환 */
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    /// 구글 로그인 성공 시 패스워드 페이지 이동
    Get.off(() => const PasswordPage());

    update();
  }

  // 로그아웃
  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}