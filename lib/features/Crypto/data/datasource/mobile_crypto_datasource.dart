import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:cryptography_plus/dart.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:linkup/features/Authentication/data/model/cryptography_model.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:linkup/features/Crypto/data/datasource/crypto_datasource.dart';
import 'package:linkup/features/Crypto/data/models/ed_key_pair_model.dart';
import 'package:linkup/features/Crypto/data/models/x_key_pair_model.dart';

CryptoDatasource getInstance() => MobileCryptoDatasource();

class MobileCryptoDatasource with HashingMixin implements CryptoDatasource {
  // Top-level method for compute
  Future<CryptographyModel> _generateCryptographyDataIsolate(
      Map<String, dynamic> args) async {
    final String? pin = args['pin'];
    final String? seedPhrase = args['seedPhrase'];
    final String userID = args['userID'];

    String? mnemonic = seedPhrase;
    String mnemonicEntropy;

    if (mnemonic == null) {
      mnemonic = bip39.generateMnemonic(strength: 128);
      mnemonicEntropy = bip39.mnemonicToEntropy(mnemonic);
    } else {
      mnemonicEntropy = bip39.mnemonicToEntropy(mnemonic);
    }

    // Key pairs generation
    final Map<String, dynamic> xKeyPair =
        await _generateXKeyPair(entropy: mnemonicEntropy, userId: userID);
    final Map<String, dynamic> edKeyPair =
        await _generateEdKeyPair(entropy: mnemonicEntropy, userId: userID);

    // Encrypt mnemonic phrase
    final String signedMnemonic = await _signData(
        message: mnemonic,
        edPrivateKey: edKeyPair["privateKey"],
        edPublicKey: edKeyPair["publicKey"]);

    final String encryptedMnemonic = await encryptData(
      data: signedMnemonic,
      senderEdKeyPair: EdKeyPairModel(
        privateKey: edKeyPair["privateKey"],
        publicKey: edKeyPair["publicKey"],
      ),
      senderXPairKey: XKeyPairModel(
        privateKey: xKeyPair["privateKey"],
        publicKey: xKeyPair["publicKey"],
      ),
      receiverXPublicKey: xKeyPair["publicKey"],
      userID: userID,
    );

    // Hash pin
    final String? pinHash = pin != null ? hashData(pin) : null;

    final Map<String, dynamic> result = {
      "edPrivateKey": edKeyPair["privateKey"],
      "edPublicKey": edKeyPair["publicKey"],
      "xPrivateKey": xKeyPair["privateKey"],
      "xPublicKey": xKeyPair["publicKey"],
      "pinHash": pinHash,
      "encryptedMnemonic": encryptedMnemonic,
    };

    return CryptographyModel.fromJson(result);
  }

  @override
  Future<CryptographyModel> generateCryptographyData(
      {String? pin, String? seedPhrase, required String userID}) async {
    return compute(_generateCryptographyDataIsolate, {
      "pin": pin,
      "seedPhrase": seedPhrase,
      "userID": userID,
    });
  }

  Future<Map<String, dynamic>> _generateEdKeyPair(
      {required String entropy, required String userId}) async {
    final entropyBytes =
        HEX.decode(await _generatePRNG(entropy, userId, "signing"));

    final ed.PrivateKey privateKey =
        ed.newKeyFromSeed(Uint8List.fromList(entropyBytes));
    final ed.PublicKey publicKey = ed.public(privateKey);

    final result = {
      "privateKey": HEX.encode(privateKey.bytes),
      "publicKey": HEX.encode(publicKey.bytes),
    };

    return result;
  }

  Future<Map<String, dynamic>> _generateXKeyPair(
      {required String entropy, required String userId}) async {
    final entropyBytes =
        HEX.decode(await _generatePRNG(entropy, userId, "key exchange"));

    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPairFromSeed(entropyBytes);

    final publicKey = await keyPair.extractPublicKey();
    final privateKey = await keyPair.extractPrivateKeyBytes();

    final result = {
      "publicKey": HEX.encode(publicKey.bytes),
      "privateKey": HEX.encode(privateKey),
    };

    return result;
  }

  Future<String> _generatePRNG(
      String entropy, String userId, String info) async {
    final salt = _deriveSaltFromUserId(userId);
    final seedBinary = HEX.decode(entropy);

    final hk1 = Hkdf(hmac: DartHmac.sha256(), outputLength: 32);
    final key = await hk1.deriveKey(
      secretKey: SecretKeyData(seedBinary),
      info: sha256.convert(utf8.encode(info)).bytes,
      nonce: salt,
    );

    final keyBytes = await key.extractBytes();

    return HEX.encode(keyBytes.sublist(0, 32));
  }

  List<int> _deriveSaltFromUserId(String userId) {
    final Uint8List bytes = utf8.encode(userId); // data being hashed

    final Digest digest = sha256.convert(bytes);

    return digest.bytes;
  }

  @override
  Future<String> encryptData({
    String? key,
    required String data,
    required EdKeyPairModel senderEdKeyPair,
    XKeyPairModel? senderXPairKey,
    String? receiverXPublicKey,
    String? userID,
  }) async {
    final algorithm = AesGcm.with256bits();

    // Generate a random secret key.
    String? secretKey = key;
    if (key == null) {
      if (userID != null) {
        secretKey = await generateSharedKey(
          senderXKeyPair: senderXPairKey!,
          receiverXPublicKey: receiverXPublicKey!,
          currentUserID: userID,
        );
      } else {
        throw Exception("User ID is undefined");
      }
    }

    final secretKeyBytes = HEX.decode(secretKey!);

    // Encrypt
    final secretBox = await algorithm.encryptString(
      data,
      secretKey: SecretKey(secretKeyBytes),
    );

    final encrypted = jsonEncode({
      "iv": HEX.encode(secretBox.nonce),
      "tag": HEX.encode(secretBox.mac.bytes),
      "encrypted": HEX.encode(secretBox.cipherText),
    });

    final String signed = await _signData(
        message: encrypted,
        edPublicKey: senderEdKeyPair.publicKey,
        edPrivateKey: senderEdKeyPair.privateKey);

    return signed;
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
    final algorithm = AesGcm.with256bits();

    final Map<String, String> parsedEncrypted = jsonDecode(encrypted);

    final List<int> iv = HEX.decode(parsedEncrypted["iv"]!);
    final List<int> tag = HEX.decode(parsedEncrypted["tag"]!);
    final List<int> encryptedBytes = HEX.decode(parsedEncrypted["encrypted"]!);

    final secretBox = SecretBox(
      encryptedBytes,
      nonce: iv,
      mac: Mac(tag),
    );

    aesKey ??= await generateSharedKey(
      senderXKeyPair: XKeyPairModel(
        privateKey: senderXKeyPair!.privateKey,
        publicKey: senderXKeyPair.publicKey,
      ),
      receiverXPublicKey: receiverXPublicKey!,
      currentUserID: currentUserID!,
    );

    final SecretKey secretKey = SecretKeyData(HEX.decode(aesKey));

    final String decrypted = await algorithm.decryptString(
      secretBox,
      secretKey: secretKey,
    );

    final bool isVerified =
        await _verifyData(signedMessage: decrypted, publicEdKey: publicEdKey);

    return {
      "decrypted": jsonDecode(decrypted)["message"],
      "isVerified": isVerified,
    };
  }

  @override
  Future<String> generateSharedKey({
    required XKeyPairModel senderXKeyPair,
    required String receiverXPublicKey,
    required String currentUserID,
    String? receiverUserID,
  }) async {
    final algorithm = X25519();

    // Current user's key pair
    final SimplePublicKey senderPublicKey = SimplePublicKey(
        HEX.decode(senderXKeyPair.publicKey),
        type: KeyPairType.x25519);
    final SimpleKeyPair senderKeyPair = SimpleKeyPairData(
        HEX.decode(senderXKeyPair.privateKey),
        publicKey: senderPublicKey,
        type: KeyPairType.x25519);

    // Other (receiver) user's public key
    final SimplePublicKey receiverPublicKey = SimplePublicKey(
        HEX.decode(receiverXPublicKey),
        type: KeyPairType.x25519);

    // Calculates shared secret
    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: senderKeyPair,
      remotePublicKey: receiverPublicKey,
    );
    final sharedSecretBytes = await sharedSecret.extractBytes();

    String? sharedId;
    if (receiverUserID != null) {
      final List<String> ids = [currentUserID, receiverUserID];
      ids.sort();
      sharedId = ids.join("_");
    }

    final String key = await _generatePRNG(HEX.encode(sharedSecretBytes),
        sharedId ?? currentUserID, "shared encryption");

    return key;
  }

  Future<String> _signData(
      {required String message,
      required String edPublicKey,
      required String edPrivateKey}) async {
    final algorithm = Ed25519();

    final SimplePublicKey publicKey =
        SimplePublicKey(HEX.decode(edPublicKey), type: KeyPairType.ed25519);
    final SimpleKeyPair keyPair = SimpleKeyPairData(HEX.decode(edPrivateKey),
        publicKey: publicKey, type: KeyPairType.ed25519);

    final signature = await algorithm.signString(
      message,
      keyPair: keyPair,
    );

    final String signedMessage = jsonEncode({
      "message": message,
      "signature": HEX.encode(signature.bytes),
    });

    return signedMessage;
  }

  Future<bool> _verifyData(
      {required String signedMessage, required String publicEdKey}) async {
    final algorithm = Ed25519();

    final Map<String, String> data = jsonDecode(signedMessage);
    final String rawMessage = data["message"]!;
    final String rawSignature = data["signature"]!;

    final SimplePublicKey publicKey =
        SimplePublicKey(HEX.decode(publicEdKey), type: KeyPairType.ed25519);
    final Signature signature =
        Signature(HEX.decode(rawSignature), publicKey: publicKey);

    final isSignatureCorrect = await algorithm.verifyString(
      rawMessage,
      signature: signature,
    );

    return isSignatureCorrect;
  }
}
