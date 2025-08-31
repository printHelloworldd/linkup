/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/private_data_entity.dart';
import 'package:linkup/core/domain/entities/user/restricted_data_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/domain/repository/firebase_messaging_repository.dart';
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/core/domain/repository/supabase_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';
import 'package:linkup/features/Authentication/domain/entity/private_cryptography_entity.dart';
import 'package:linkup/features/Authentication/domain/entity/public_cryptography_entity.dart';

class InsertUserUsecaseToRdb {
  final FirestoreRepository firestoreRepository;
  final SupabaseRepository supabaseRepository;
  final SecureStorageRepository secureStorageRepository;
  final CryptoRepository cryptoRepository;
  final FirebaseMessagingRepository firebaseMessagingRepository;

  InsertUserUsecaseToRdb({
    required this.firestoreRepository,
    required this.supabaseRepository,
    required this.secureStorageRepository,
    required this.cryptoRepository,
    required this.firebaseMessagingRepository,
  });

  Future<void> call({required UserEntity user, required String pin}) async {
    final String userID = user.id;

    // upload profile image to supabase
    if (user.profileImage != null) {
      if (user.profileImage!.isNotEmpty) {
        supabaseRepository.uploadProfileImage(userID, user.profileImage!);
      }
    }

    final CryptographyEntity? cryptographyEntity = await cryptoRepository
        .generateCryptographyData(pin: pin, currentUserID: userID);

    if (cryptographyEntity != null) {
      final PublicCryptographyEntity publicData = PublicCryptographyEntity(
        xPublicKey: cryptographyEntity.xPublicKey,
        edPublicKey: cryptographyEntity.edPublicKey,
        pinHash: cryptographyEntity.pinHash,
        encryptedMnemonic: cryptographyEntity.encryptedMnemonic,
      );

      final Either<Failure, String> result =
          await firebaseMessagingRepository.initNotifications(userID);
      String? fcmToken;
      result.fold(
        (failure) => {fcmToken = null},
        (token) => fcmToken = token,
      );

      // Save private keys into secure local storage
      final PrivateCryptographyEntity privateData = PrivateCryptographyEntity(
        xPrivateKey: cryptographyEntity.xPrivateKey,
        edPrivateKey: cryptographyEntity.edPrivateKey,
        encryptedMnemonic: cryptographyEntity.encryptedMnemonic,
      );

      final UserEntity updatedUser = user.copyWith(
        restrictedDataEntity: RestrictedDataEntity(
          fcmToken: fcmToken,
          edPublicKey: publicData.edPublicKey!,
          xPublicKey: publicData.xPublicKey!,
        ),
        privateDataEntity: PrivateDataEntity(
          edPrivateKey: privateData.edPrivateKey,
          xPrivateKey: privateData.xPrivateKey,
          encryptedMnemonic: privateData.encryptedMnemonic ?? "",
          pinHash: publicData.pinHash ?? "",
          isVerified: false,
        ),
      );

      await firestoreRepository.insertUserToFirestore(updatedUser);

      await secureStorageRepository.savePrivateData(
          privateData: privateData, userID: userID);
    }
  }
}
