part of 'crypto_bloc.dart';

sealed class CryptoState extends Equatable {
  const CryptoState();

  @override
  List<Object> get props => [];
}

final class CryptoInitial extends CryptoState {}

// TODO: Rename class
final class Loading extends CryptoState {}

final class DecryptedData extends CryptoState {
  final String decryptedData;

  const DecryptedData({required this.decryptedData});
}

final class CheckingPin extends CryptoState {}

final class PinIsValid extends CryptoState {}

final class PinIsInvalid extends CryptoState {}

final class CheckingPinFailure extends CryptoState {}

final class GeneratingData extends CryptoState {}

final class GeneratingDataFailure extends CryptoState {}

final class GeneratedData extends CryptoState {
  final CryptographyEntity cryptographyData;

  const GeneratedData({required this.cryptographyData});
}

//* From server
final class RecoveringData extends CryptoState {}

final class RecoveringDataFailure extends CryptoState {}

final class RecoveredData extends CryptoState {}
