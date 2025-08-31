/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';

abstract class CryptoRepository {
  Future<CryptographyEntity?> generateCryptographyData(
      {String? pin, String? seedPhrase, required String currentUserID});

  Future<bool> isDataEqual(String data, String hash);

  Future<Map<String, dynamic>?> decryptData({
    required String currentUserID,
    String? key,
    required String data,
    required String publicEdKey,
    String? senderXPrivateKey,
    String? senderXPublicKey,
    String? receiverXPublicKey,
  });

  Future<String?> encryptData({
    String? key,
    required String data,
    required String privateEdKey,
    required String publicEdKey,
    String? xPrivateKey,
    String? xPublicKey,
    required String currentUserID,
  });

  Future<String?> generateSharedKey({
    required String currentUserPrivateXKey,
    required String currentUserPublicXKey,
    required String otherUserPublicXKey,
    required String currentUserID,
    required String receiverUserID,
  });
}
