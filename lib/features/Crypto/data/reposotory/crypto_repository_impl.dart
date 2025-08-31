// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/features/Crypto/data/datasource/crypto_datasource.dart';
import 'package:linkup/features/Authentication/data/model/cryptography_model.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';
import 'package:linkup/features/Crypto/data/models/ed_key_pair_model.dart';
import 'package:linkup/features/Crypto/data/models/x_key_pair_model.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoDatasource cryptoDatasource;

  CryptoRepositoryImpl({required this.cryptoDatasource});

  @override
  Future<bool> isDataEqual(String data, String hash) async {
    return await cryptoDatasource.verifyPin(pin: data, storedHash: hash);
  }

  @override
  Future<CryptographyEntity?> generateCryptographyData(
      {String? pin, String? seedPhrase, required String currentUserID}) async {
    final CryptographyModel rawData =
        await cryptoDatasource.generateCryptographyData(
            pin: pin, seedPhrase: seedPhrase, userID: currentUserID);

    return rawData.toEntity();
  }

  @override
  Future<Map<String, dynamic>?> decryptData({
    required String currentUserID,
    String? key,
    required String data,
    required String publicEdKey,
    String? senderXPrivateKey,
    String? senderXPublicKey,
    String? receiverXPublicKey,
  }) async {
    final Map<String, dynamic>? rawData = await cryptoDatasource.decryptData(
      aesKey: key,
      encrypted: data,
      publicEdKey: publicEdKey,
      currentUserID: currentUserID,
      senderXKeyPair: senderXPrivateKey == null || senderXPublicKey == null
          ? null
          : XKeyPairModel(
              privateKey: senderXPrivateKey,
              publicKey: senderXPublicKey,
            ),
      receiverXPublicKey: receiverXPublicKey,
    );

    return rawData;
  }

  @override
  Future<String?> encryptData({
    String? key,
    required String data,
    required String privateEdKey,
    required String publicEdKey,
    String? xPrivateKey,
    String? xPublicKey,
    required String currentUserID,
  }) async {
    return await cryptoDatasource.encryptData(
      key: key,
      data: data,
      senderEdKeyPair: EdKeyPairModel(
        privateKey: privateEdKey,
        publicKey: publicEdKey,
      ),
      receiverXPublicKey: xPublicKey,
      userID: currentUserID,
    );
  }

  @override
  Future<String?> generateSharedKey({
    required String currentUserPrivateXKey,
    required String currentUserPublicXKey,
    required String otherUserPublicXKey,
    required String currentUserID,
    required String receiverUserID,
  }) async {
    return await cryptoDatasource.generateSharedKey(
      senderXKeyPair: XKeyPairModel(
        privateKey: currentUserPrivateXKey,
        publicKey: currentUserPublicXKey,
      ),
      receiverXPublicKey: otherUserPublicXKey,
      currentUserID: currentUserID,
      receiverUserID: receiverUserID,
    );
  }
}
