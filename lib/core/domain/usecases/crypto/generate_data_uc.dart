/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class GenerateDataUc {
  final CryptoRepository cryptoRepository;
  final FirebaseAuthRepository firebaseAuthRepository;

  GenerateDataUc({
    required this.cryptoRepository,
    required this.firebaseAuthRepository,
  });

  Future<CryptographyEntity?> call(String? seedPhrase) async {
    final String? userID = firebaseAuthRepository.getCurrentUserID();

    if (userID == null) return null;

    return await cryptoRepository.generateCryptographyData(
        seedPhrase: seedPhrase, currentUserID: userID);
  }
}
