// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/domain/repository/firebase_messaging_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/core/utils.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class SendMessageUc {
  final ChatRepository chatRepository;
  final FirebaseMessagingRepository firebaseMessagingRepository;
  final CryptoRepository cryptoRepository;

  SendMessageUc({
    required this.chatRepository,
    required this.firebaseMessagingRepository,
    required this.cryptoRepository,
  });

  Future<Either<Failure, Unit>> call({
    required UserEntity receiverUser,
    required UserEntity senderUser,
    required String message,
    required ChatEntity chat,
    Map<String, dynamic>? reply,
  }) async {
    if (receiverUser.blockedUsers.contains(senderUser.id)) {
      return const Right(unit);
    } else {
      try {
        final String? encryptedMessage = await cryptoRepository.encryptData(
          data: message,
          publicEdKey: senderUser.restrictedDataEntity!.edPublicKey,
          privateEdKey: senderUser.privateDataEntity!.edPrivateKey!,
          currentUserID: senderUser.id,
          key: chat.sharedKey,
        );

        if (encryptedMessage == null) {
          return Left(CommonFailure("Failed to encrypt message"));
        }

        final Either<Failure, Unit> sendResult =
            await chatRepository.sendMessage(
          receiverUser: receiverUser,
          senderUser: senderUser,
          encryptedMessage: encryptedMessage,
          chat: chat,
          reply: reply,
        );

        if (sendResult.isLeft()) {
          return sendResult;
        }

        final String chatID = Utils.getChatID(
            currentUserID: senderUser.id, otherUserID: receiverUser.id);
        final Either<Failure, bool> isChatMuted = await chatRepository
            .isChatMuted(chatID: chatID, userID: receiverUser.id);

        final bool shouldSendNotification = isChatMuted.fold(
          (_) => true,
          (muted) => !muted,
        );

        if (shouldSendNotification) {
          await firebaseMessagingRepository.sendNotification(
            senderUserID: senderUser.id,
            senderUserName: senderUser.fullName,
            msg: message,
            fcmToken: receiverUser.restrictedDataEntity?.fcmToken,
          );
        }

        return const Right(unit);
      } catch (e) {
        return Left(CommonFailure(e.toString()));
      }
    }
  }
}
