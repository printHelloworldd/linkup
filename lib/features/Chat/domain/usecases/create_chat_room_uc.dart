import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class CreateChatRoomUc {
  final ChatRepository chatRepository;
  final CryptoRepository cryptoRepository;
  final SecureStorageRepository secureStorageRepository;

  CreateChatRoomUc({
    required this.chatRepository,
    required this.cryptoRepository,
    required this.secureStorageRepository,
  });

  Future<Either<Failure, ChatEntity>> call(
      UserEntity receiverUser, UserEntity currentUser) async {
    if (UserEntity.isPrivateDataEmpty(currentUser.privateDataEntity)) {
      return Left(CommonFailure(
          "Connot create a chat because there is no private crypto data"));
    }

    if (UserEntity.isRestrictedDataEmpty(receiverUser.restrictedDataEntity)) {
      return Left(CommonFailure(
          "Cannot create a chat beacause receiver user has no crypto data"));
    }

    final String? sharedKey = await cryptoRepository.generateSharedKey(
      currentUserPrivateXKey: currentUser.privateDataEntity!.xPrivateKey!,
      currentUserPublicXKey: currentUser.restrictedDataEntity!.xPublicKey,
      otherUserPublicXKey: receiverUser.restrictedDataEntity!.xPublicKey,
      currentUserID: currentUser.id,
      receiverUserID: receiverUser.id,
    );

    if (sharedKey == null) {
      return Left(CommonFailure("Failed to generate shared key for the chat"));
    }

    final Either<Failure, ChatEntity> chatResult = await chatRepository
        .createChatRoom(receiverUser.id, sharedKey, currentUser.id);

    chatResult.fold((failure) {
      return failure;
    }, (chat) async {
      await secureStorageRepository.saveChatSharedKey(
          chatID: chat.chatID, sharedKey: sharedKey);
    });

    return chatResult;
  }
}
