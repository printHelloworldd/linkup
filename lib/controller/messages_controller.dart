import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';

class MessagesController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    // final Future<RemoteMessage?> remoteMessage =
    //     FirebaseMessaging.instance.getInitialMessage();

    // remoteMessage.then((msg) {
    //   if (msg != null) {
    //     _firebaseMessagingBackgroundHandler(msg);
    //   }
    // });
  }

  void _firebaseMessagingForegroundHandler(RemoteMessage message) {
    final colors = Get.theme.extension<AppColors>()!;

    Get.rawSnackbar(
      titleText: Text(
        message.notification?.title ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.background,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message.notification?.body ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.background,
          fontSize: 12,
        ),
      ),
      isDismissible: true,
      duration: const Duration(seconds: 5),
      backgroundColor: colors.secondary,
      snackPosition: SnackPosition.TOP,
      icon: Icon(
        MingCuteIcons.mgc_mail_line,
        color: colors.background,
        size: 35,
      ),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  // _firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) {
  //   final String senderUserID = remoteMessage.data["senderID"];

  //   Navigator.push(
  //     context,
  //   );
  // }
}
