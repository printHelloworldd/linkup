/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingDatasource {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getFCMToken(String userId, {String? newToken}) async {
    try {
      final notiSettings = await _firebaseMessaging.getNotificationSettings();
      if (notiSettings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      const vapidKey = String.fromEnvironment('WEB_VAPID_KEY');

      String? newToken = await _firebaseMessaging.getToken(vapidKey: vapidKey);
      if (kDebugMode) {
        print("Token = $newToken");
      }

      if (newToken == null) throw Exception("Failed to get new FCM token");

      return newToken;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to init notifications: $e");
      }
      throw Exception(e.toString());
    }
  }

  Future<void> sendNotification({
    required String senderIDToken,
    required String senderUserID,
    required String senderUserName,
    required String msg,
    required String? fcmToken,
  }) async {
    final uri =
        Uri.parse("https://fcm-service.onrender.com/send-push-notification");

    final body = jsonEncode({
      "idToken": senderIDToken,
      "fcmToken": fcmToken,
      "title": senderUserName,
      "senderUserId": senderUserID,
      "body": msg,
    });

    final headers = {
      "Content-Type": "application/json",
    };

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send notification: ${response.statusCode} ${response.body}');
      } else if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Notification sent");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send notification: $e');
      }

      throw Exception(e.toString());
    }
  }
}
