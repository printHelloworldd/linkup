import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/entities/message.dart';
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class GetMessagesUc {
  final ChatRepository chatRepository;
  final CryptoRepository cryptoRepository;

  GetMessagesUc({required this.chatRepository, required this.cryptoRepository});

  Stream<Either<Failure, List<MessageEntity>>> call(
      UserEntity currentUser, ChatEntity chat) {
    final UserEntity receiverUser = chat.receiverUser;

    return chatRepository
        .getMessages(currentUser, receiverUser, chat)
        .asyncMap((messagesResult) async {
      List<MessageEntity> updatedMessages = [];

      if (messagesResult.isLeft()) {
        return Left(CommonFailure("Failed to get messages from DB"));
      }

      final messages = messagesResult.getOrElse(() => []);

      for (MessageEntity message in messages) {
        final String edPublicKey = message.senderID == currentUser.id
            ? currentUser.restrictedDataEntity!.edPublicKey
            : chat.receiverUser.restrictedDataEntity!.edPublicKey;

        final Map<String, dynamic>? decrypted =
            await cryptoRepository.decryptData(
          currentUserID: currentUser.id,
          data: message.message,
          publicEdKey: edPublicKey,
          key: chat.sharedKey,
        );

        message = message.copyWith(
          message: decrypted?["decrypted"] ?? "***",
          isVerified: decrypted?["isVerified"] ?? false,
        );

        updatedMessages.add(message);
      }

      return Right(updatedMessages);
    });
  }
}
