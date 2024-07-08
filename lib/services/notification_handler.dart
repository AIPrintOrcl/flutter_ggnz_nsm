import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> initialiseNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  const String darwinNotificationCategoryText = 'textCategory';

  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          darwinNotificationCategoryText,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text(
              'text_1',
              'Action 1',
              buttonTitle: 'Send',
              placeholder: 'Placeholder',
            ),
          ],
        ),
      ];
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      /*didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );*/
    },
    notificationCategories: darwinNotificationCategories,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
      /*switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:

      }*/
    },
  );
}