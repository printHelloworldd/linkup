/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';
import 'package:linkup/features/Authentication/domain/entity/private_cryptography_entity.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class RecoverDataUc {
  final CryptoRepository cryptoRepository;
  final SecureStorageRepository secureStorageRepository;
  final FirebaseAuthRepository firebaseAuthRepository;

  RecoverDataUc({
    required this.cryptoRepository,
    required this.secureStorageRepository,
    required this.firebaseAuthRepository,
  });

  Future<void> call(CryptographyEntity cryptoData) async {
    final PrivateCryptographyEntity privateData = PrivateCryptographyEntity(
      xPrivateKey: cryptoData.xPrivateKey,
      edPrivateKey: cryptoData.edPrivateKey,
      encryptedMnemonic: cryptoData.encryptedMnemonic,
    );

    final String? userID = firebaseAuthRepository.getCurrentUserID();

    if (userID == null) return;

    await secureStorageRepository.savePrivateData(
        privateData: privateData, userID: userID);
  }
}
