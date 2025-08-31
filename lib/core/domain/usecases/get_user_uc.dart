/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/core/domain/repository/supabase_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/entity/private_cryptography_entity.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class GetUserUc {
  final FirestoreRepository firestoreRepository;
  final SupabaseRepository supabaseRepository;
  final FirebaseAuthRepository firebaseAuthRepository;
  final SecureStorageRepository secureStorageRepository;

  GetUserUc({
    required this.firestoreRepository,
    required this.supabaseRepository,
    required this.firebaseAuthRepository,
    required this.secureStorageRepository,
  });

  Future<Either<Failure, Option<UserEntity?>>> call(String userID) async {
    final Either<Failure, UserEntity?> rawData =
        await firestoreRepository.getUserData(userID);

    if (rawData.isLeft()) return Left(CommonFailure("Failed to get user data"));

    final UserEntity? user = rawData.getOrElse(() => null);
    if (user == null) return Right(none());

    final profileImage = await supabaseRepository.getProfileImageUrl(userID);

    final String? currentUserID = firebaseAuthRepository.getCurrentUserID();

    PrivateDataEntity? privateDataEntity;
    if (currentUserID != null) {
      final Either<Failure, Option<PrivateCryptographyEntity>> cryptoResult =
          await secureStorageRepository.getPrivateData(currentUserID);

      cryptoResult.fold((failure) {
        if (kDebugMode) {
          print(
              "Failed to get crypto data from Secure Storage: ${failure.message}");
        }
        return Left(CommonFailure(
            "Failed to get crypto data from Secure Storage: ${failure.message}"));
      }, (option) {
        option.fold(() {
          if (kDebugMode) {
            print("Private crypto data is null");
          }
          return null;
        }, (privateCryptoData) {
          privateDataEntity = PrivateDataEntity(
            edPrivateKey: privateCryptoData.edPrivateKey,
            xPrivateKey: privateCryptoData.xPrivateKey,
            encryptedMnemonic: privateCryptoData.encryptedMnemonic ??
                user.privateDataEntity?.encryptedMnemonic ??
                "",
            pinHash: privateCryptoData.pinHash ??
                user.privateDataEntity?.pinHash ??
                "",
            isVerified: user.privateDataEntity?.isVerified ?? false,
          );
        });
      });
    }

    return Right(Some(user.copyWith(
      profileImageUrl: profileImage,
      privateDataEntity: privateDataEntity,
    )));
  }
}
