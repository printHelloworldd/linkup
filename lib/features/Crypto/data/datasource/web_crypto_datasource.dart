// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'package:flutter_node_worker/flutter_node_worker.dart';
import 'package:linkup/features/Authentication/data/model/cryptography_model.dart';
import 'package:linkup/features/Crypto/data/datasource/crypto_datasource.dart';
import 'package:linkup/features/Crypto/data/models/ed_key_pair_model.dart';
import 'package:linkup/features/Crypto/data/models/x_key_pair_model.dart';

CryptoDatasource getInstance() => WebCryptoDatasource();

class WebCryptoDatasource with HashingMixin implements CryptoDatasource {
  final worker = FlutterNodeWorker(path: "workers/crypto_worker.js");

  @override
  Future<CryptographyModel> generateCryptographyData(
      {String? pin, String? seedPhrase, required String userID}) async {
    final Map<String, dynamic> message = {
      "pin": pin,
      "seedPhrase": seedPhrase,
      "userID": userID,
    };

    final Map<String, dynamic>? result = await worker.compute(
      command: "generate_data",
      data: message,
    );

    if (result == null || result.isEmpty) {
      throw Exception("Failed to generate crypto data");
    }

    final CryptographyModel cryptographyModel =
        CryptographyModel.fromJson(result);

    return cryptographyModel;
  }

  @override
  Future<String?> encryptData({
    String? key,
    required String data,
    required EdKeyPairModel senderEdKeyPair,
    XKeyPairModel? senderXPairKey,
    String? receiverXPublicKey,
    String? userID,
  }) async {
    final Map<String, dynamic> message = {
      "message": data,
      "privateKey": senderEdKeyPair.privateKey,
      "key": key,
      "xPrivateKey": senderXPairKey?.privateKey,
      "xPublicKey": receiverXPublicKey,
      "userID": userID,
    };

    final Map<String, dynamic>? result = await worker.compute(
      command: "encrypt",
      data: message,
    );

    return result?["encrypted"];
  }

  @override
  Future<Map<String, dynamic>?> decryptData({
    String? aesKey,
    required String encrypted,
    required String publicEdKey,
    XKeyPairModel? senderXKeyPair,
    String? receiverXPublicKey,
    String? currentUserID,
  }) async {
    final Map<String, dynamic> message = {
      "encrypted": encrypted,
      "edPublicKey": publicEdKey,
      "xPrivateKey": senderXKeyPair?.privateKey,
      "xPublicKey": receiverXPublicKey,
      "userID": currentUserID,
      "key": aesKey,
    };

    final Map<String, dynamic>? result =
        await worker.compute(command: "decrypt", data: message);

    return result;
  }

  @override
  Future<String> generateSharedKey({
    required XKeyPairModel senderXKeyPair,
    required String receiverXPublicKey,
    required String currentUserID,
    String? receiverUserID,
  }) async {
    if (receiverUserID == null) throw Exception("Receiver user id is null");
    final List<String> ids = [currentUserID, receiverUserID];
    ids.sort();
    final String sharedID = ids.join("_");

    final Map<String, dynamic> message = {
      "userIDs": sharedID,
      "publicKey": receiverXPublicKey,
      "privateKey": senderXKeyPair.privateKey,
    };

    final Map<String, dynamic>? result =
        await worker.compute(command: "generate_shared_key", data: message);

    return result?["sharedKey"];
  }
}
