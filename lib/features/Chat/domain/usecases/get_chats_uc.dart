import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/crypto_repository.dart';
import 'package:linkup/core/domain/repository/secure_storage_repository.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class GetChatsUc {
  final ChatRepository chatRepository;
  final SecureStorageRepository secureStorageRepository;
  final CryptoRepository cryptoRepository;

  GetChatsUc({
    required this.chatRepository,
    required this.secureStorageRepository,
    required this.cryptoRepository,
  });

  Stream<Either<Failure, List<ChatEntity>>> call(UserEntity currentUser) {
    return chatRepository
        .getAllChats(currentUser)
        .asyncMap((chatsResult) async {
      List<ChatEntity> updatedChats = [];

      if (chatsResult.isLeft()) {
        return Left(CommonFailure("Failed to get chats from DB"));
      }

      final chats = chatsResult.getOrElse(() => []);

      for (var chat in chats) {
        final String chatId = chat.chatID;

        Either<Failure, Option<String>> sharedKeyResult =
            await secureStorageRepository.getChatSharedKey(chatID: chatId);

        // sharedKeyResult.fold((failure) {}, (option) {
        //   option.fold(() {}, (sharedKey) {});
        // });

        final Option<String> sharedKeyO =
            sharedKeyResult.getOrElse(() => none());

        String? sharedKey = sharedKeyO.getOrElse(() => "");
        if (sharedKeyResult.isLeft() ||
            sharedKeyO.isNone() ||
            sharedKey.isEmpty) {
          sharedKey = await cryptoRepository.generateSharedKey(
            currentUserPrivateXKey: currentUser.privateDataEntity!.xPrivateKey!,
            currentUserPublicXKey: currentUser.restrictedDataEntity!.xPublicKey,
            otherUserPublicXKey:
                chat.receiverUser.restrictedDataEntity!.xPublicKey,
            currentUserID: currentUser.id,
            receiverUserID: chat.receiverUser.id,
          );
        }

        if (sharedKey == null) {
          continue;
        }

        chat = chat.copyWith(
          sharedKey: sharedKey,
        );

        // Decrypts the last message
        if (chat.lastMessage != null) {
          final String encryptedMessage = chat.lastMessage!.message;
          String decryptedMessage = "***";
          bool isVerified = false;

          final String edPublicKey =
              chat.lastMessage!.senderID == currentUser.id
                  ? currentUser.restrictedDataEntity!.edPublicKey
                  : chat.receiverUser.restrictedDataEntity!.edPublicKey;

          final Map<String, dynamic>? rawData =
              await cryptoRepository.decryptData(
            key: chat.sharedKey,
            data: encryptedMessage,
            publicEdKey: edPublicKey,
            currentUserID: currentUser.id,
          );

          if (rawData != null) {
            decryptedMessage = rawData["decrypted"];
            isVerified = rawData["isVerified"];
          }

          chat = chat.copyWith(
            lastMessage: chat.lastMessage!.copyWith(
              message: decryptedMessage,
              isVerified: isVerified,
            ),
          );
        }

        updatedChats.add(chat);
      }

      return Right(_filterBlockedChats(updatedChats, currentUser));
    });
  }

  List<ChatEntity> _filterBlockedChats(
      List<ChatEntity> chats, UserEntity user) {
    final blockedSet = user.blockedUsers.toSet();

    if (blockedSet.isEmpty) return chats;

    final filteredChats = chats
        .where((chat) => !blockedSet.contains(chat.receiverUser.id))
        .toList();

    return filteredChats;
  }
}
