import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:cryptography_plus/helpers.dart';
import 'package:hex/hex.dart';
import 'package:linkup/features/Authentication/data/model/cryptography_model.dart';
import 'package:linkup/features/Crypto/data/datasource/crypto_helper.dart'
    if (dart.library.js) 'package:linkup/features/Crypto/data/datasource/web_crypto_datasource.dart'
    if (dart.library.io) 'package:linkup/features/Crypto/data/datasource/mobile_crypto_datasource.dart';
import 'package:linkup/features/Crypto/data/models/ed_key_pair_model.dart';
import 'package:linkup/features/Crypto/data/models/x_key_pair_model.dart';

mixin HashingMixin {
  String hashData(String data) {
    final Uint8List bytes = utf8.encode(data); // data being hashed

    final Digest digest = sha256.convert(bytes);

    return HEX.encode(digest.bytes);
  }

  Future<String> hashPin(String pin) async {
    final saltBytes = randomBytes(16);
    final algorithm = Argon2id(
      memory: 10 * 1000, // 10 MB
      parallelism: 2, // Use maximum two CPU cores.
      iterations:
          100, // For more security, you should usually raise memory parameter, not iterations.
      hashLength: 32, // Number of bytes in the returned hash
    );

    final secretKey = await algorithm.deriveKeyFromPassword(
      password: pin,
      nonce: saltBytes,
    );
    final secretKeyBytes = await secretKey.extractBytes();

    return jsonEncode({
      "salt": HEX.encode(saltBytes),
      "hash": HEX.encode(secretKeyBytes),
    });
  }

  Future<bool> verifyPin(
      {required String pin, required String storedHash}) async {
    final Map<String, String> storedData = jsonDecode(storedHash);

    final algorithm = Argon2id(
      memory: 10 * 1000, // 10 MB
      parallelism: 2, // Use maximum two CPU cores.
      iterations:
          100, // For more security, you should usually raise memory parameter, not iterations.
      hashLength: 32, // Number of bytes in the returned hash
    );

    final secretKey = await algorithm.deriveKeyFromPassword(
      password: pin,
      nonce: HEX.decode(storedData["salt"]!),
    );
    final secretKeyBytes = await secretKey.extractBytes();

    return HEX.encode(secretKeyBytes) == storedData["hash"]!;
  }
}

abstract class CryptoDatasource with HashingMixin {
  factory CryptoDatasource() => getInstance();

  Future<CryptographyModel> generateCryptographyData(
      {String? pin, String? seedPhrase, required String userID});

  Future<String?> encryptData({
    String? key,
    required String data,
    required EdKeyPairModel senderEdKeyPair,
    XKeyPairModel? senderXPairKey,
    String? receiverXPublicKey,
    String? userID,
  });

  Future<Map<String, dynamic>?> decryptData({
    String? aesKey,
    required String encrypted,
    required String publicEdKey,
    XKeyPairModel? senderXKeyPair,
    String? receiverXPublicKey,
    String? currentUserID,
  });

  Future<String> generateSharedKey({
    required XKeyPairModel senderXKeyPair,
    required String receiverXPublicKey,
    required String currentUserID,
    String? receiverUserID,
  });
}
