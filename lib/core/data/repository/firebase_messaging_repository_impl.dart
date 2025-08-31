/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/data/datasources/local/secure_storage_datasource.dart';
import 'package:linkup/core/data/datasources/remote/firebase_messaging_datasource.dart';
import 'package:linkup/core/data/datasources/remote/firestore_datasource.dart';
import 'package:linkup/core/data/datasources/remote/supabase_datasource.dart';
import 'package:linkup/core/domain/repository/firebase_messaging_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';

class FirebaseMessagingRepositoryImpl implements FirebaseMessagingRepository {
  final FirebaseMessagingDatasource firebaseMessagingDatasource;
  final SecureStorageDatasource secureStorageDatasource;
  final FirestoreDatasource firestoreDatasource;
  final SupabaseDatasource supabaseDatasource;
  final FirebaseAuthDatasource firebaseAuthDatasource;

  FirebaseMessagingRepositoryImpl({
    required this.firebaseMessagingDatasource,
    required this.secureStorageDatasource,
    required this.firestoreDatasource,
    required this.supabaseDatasource,
    required this.firebaseAuthDatasource,
  });

  @override
  Future<Either<Failure, String>> initNotifications(String userID) async {
    try {
      final String newToken =
          await firebaseMessagingDatasource.getFCMToken(userID);
      final String? savedToken = await secureStorageDatasource.getToken(userID);

      if (newToken != savedToken) {
        await secureStorageDatasource.saveToken(userID, newToken);
        await firestoreDatasource.saveTokenToDatabase(userID, newToken);
        // await supabaseDatasource.saveFcmToken(userID, newToken);
      }

      // final String? supabaseToken = await supabaseDatasource.getFcmToken(userID);
      // if (supabaseToken != newToken && newToken != null) {
      //   await supabaseDatasource.saveFcmToken(userID, newToken);
      // }

      return Right(newToken);
    } on Exception catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<void> sendNotification({
    required String senderUserID,
    required String senderUserName,
    required String msg,
    required String? fcmToken,
  }) async {
    final String? senderIDToken = await firebaseAuthDatasource.getUserIdToken();

    if (senderIDToken == null) return;

    await firebaseMessagingDatasource.sendNotification(
      senderIDToken: senderIDToken,
      senderUserID: senderUserID,
      senderUserName: senderUserName,
      msg: msg,
      fcmToken: fcmToken,
    );
  }
}
