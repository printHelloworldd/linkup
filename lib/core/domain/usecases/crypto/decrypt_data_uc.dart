/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/crypto_repository.dart';

class DecryptDataUc {
  final CryptoRepository cryptoRepository;

  DecryptDataUc({required this.cryptoRepository});

  Future<String> call({
    required String encryptedData,
    required String edPublicKey,
    String? senderXPrivateKey,
    String? senderXPublicKey,
    String? receiverXPublicKey,
    required String userID,
  }) async {
    final Map<String, dynamic>? rawData = await cryptoRepository.decryptData(
      data: encryptedData,
      publicEdKey: edPublicKey,
      senderXPrivateKey: senderXPrivateKey,
      senderXPublicKey: senderXPublicKey,
      receiverXPublicKey: receiverXPublicKey,
      currentUserID: userID,
    );

    if (rawData != null) {
      return rawData["decrypted"];
    } else {
      throw Exception("Failed to decrypt data");
    }
  }
}
