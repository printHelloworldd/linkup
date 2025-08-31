// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'crypto_bloc.dart';

sealed class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object> get props => [];
}

class DecryptData extends CryptoEvent {
  final String encryptedData;
  final String edPublicKey;
  final String? receiverXPublicKey;
  final String? senderXPrivateKey;
  final String? senderXPublicKey;
  final String userID;

  const DecryptData({
    required this.encryptedData,
    required this.edPublicKey,
    this.receiverXPublicKey,
    this.senderXPrivateKey,
    this.senderXPublicKey,
    required this.userID,
  });
}

class CheckPin extends CryptoEvent {
  final String data;
  final String hash;

  const CheckPin({required this.data, required this.hash});
}

class GenerateData extends CryptoEvent {
  final String? seedPhrase;

  const GenerateData({this.seedPhrase});
}

//* From server
class RecoverData extends CryptoEvent {
  final UserEntity user;

  const RecoverData({required this.user});
}
