import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

Future<bool> checkPermission() async {
  bool status = await Permission.storage.isGranted;
  return status;
}

Future<bool> getStoragePermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  if (statuses[Permission.storage] == PermissionStatus.permanentlyDenied) {
    openAppSettings();
  }

  return Future.value(true);
}

Future<bool> getPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.systemAlertWindow,
  ].request();

  return Future.value(true);
}

Future<void> getAndroidNotificationPermission() async {
  if (Platform.isAndroid) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  }
}

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
