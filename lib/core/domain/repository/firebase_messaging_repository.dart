/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/failures/failure.dart';

abstract class FirebaseMessagingRepository {
  Future<Either<Failure, String>> initNotifications(String userID);
  Future<void> sendNotification({
    required String senderUserID,
    required String senderUserName,
    required String msg,
    required String? fcmToken,
  });
}
