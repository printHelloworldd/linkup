import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/crypto/check_pin_uc.dart';
import 'package:linkup/core/domain/usecases/crypto/decrypt_data_uc.dart';
import 'package:linkup/core/domain/usecases/crypto/generate_data_uc.dart';
import 'package:linkup/features/Authentication/domain/entity/cryptography_entity.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final DecryptDataUc decryptDataUc;
  final CheckPinUc checkPinUc;
  final GenerateDataUc generateDataUc;

  CryptoBloc({
    required this.decryptDataUc,
    required this.checkPinUc,
    required this.generateDataUc,
  }) : super(CryptoInitial()) {
    on<DecryptData>((event, emit) async {
      emit(Loading());

      final String result = await decryptDataUc(
        edPublicKey: event.edPublicKey,
        encryptedData: event.encryptedData,
        receiverXPublicKey: event.receiverXPublicKey,
        senderXPrivateKey: event.senderXPrivateKey,
        senderXPublicKey: event.senderXPublicKey,
        userID: event.userID,
      );

      emit(DecryptedData(decryptedData: result));
    });

    on<CheckPin>((event, emit) async {
      emit(CheckingPin());

      final bool result = await checkPinUc(event.data, event.hash);

      if (result) {
        emit(PinIsValid());
      } else {
        emit(PinIsInvalid());
      }
    });

    on<GenerateData>((event, emit) async {
      try {
        emit(GeneratingData());

        final CryptographyEntity? cryptographyData =
            await generateDataUc(event.seedPhrase);

        if (cryptographyData != null) {
          emit(GeneratedData(cryptographyData: cryptographyData));
        } else {
          emit(GeneratingDataFailure());
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to generate data: $e");
        }
        emit(GeneratingDataFailure());
      }
    });

    on<RecoverData>((event, emit) {
      // TODO: implement event handler
    });
  }
}
