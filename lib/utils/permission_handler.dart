import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

// 권한 관련 유틸
Future<bool> checkPermission() async {
  bool status = await Permission.storage.isGranted;
  return status;
}

// 저장 권한 요청
Future<bool> getStoragePermission() async {

  /// 권한 요청
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage, /* 외부 저장소 접근을 위한 권한 */
  ].request();

  /// 권한 상태 확인. 만약 저장 권한이 영구적으로 거부된 경우 앱 설정을 열어 사용자에게 수동으로 권한 부여 가능하도록 한다.
  if (statuses[Permission.storage] == PermissionStatus.permanentlyDenied) { /* permanentlyDenied : 요청한 기능에 대한 권한이 영구적으로 거부되었습니다. 이 권한을 요청할 때는 대화 상자가 표시되지 않습니다. 사용자는 다음을 수행할 수 있습니다. */
    openAppSettings(); /* openAppSettings() : 앱 설정 페이지를 엽니다. 앱 설정 페이지를 열 수 있으면 [true]를 반환하고, 그렇지 않으면 [false]를 반환합니다. */
  }

  return Future.value(true);
}

// 시스템 알림창 권한을 요청
Future<bool> getPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.systemAlertWindow, /* 시스템 알림창 권한 요청 */
  ].request();

  return Future.value(true);
}

// Android에서 알림 권한을 요청
Future<void> getAndroidNotificationPermission() async {
  if (Platform.isAndroid) { /* 1. 플랫폼 확인 : 안드로이드 확인 */
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); /* 3. 플러그인 초기화 : Android와 iOS 기기 모두에서 알림을 표시하는 데 사용 */
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission(); /* 4. 플랫폼별 구현 해결 -> 'requestPermission' Android 13 이상에 적용 가능한 메서드를 사용하여 알림 권한을 요청 */
  }
}

// IOS에서 알림 권한을 요청
Future<void> getIOSNotificationPermission() async {
  if (Platform.isIOS) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
