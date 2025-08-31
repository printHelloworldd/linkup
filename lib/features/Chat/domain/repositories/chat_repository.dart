import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatEntity>> createChatRoom(
      String receiverID, String sharedKey, String currentUserID);

  Stream<Either<Failure, List<ChatEntity>>> getAllChats(UserEntity currentUser);

  Future<Either<Failure, Unit>> sendMessage({
    required UserEntity receiverUser,
    required UserEntity senderUser,
    required String encryptedMessage,
    Map<String, dynamic>? reply,
    required ChatEntity chat,
  });

  Future<Either<Failure, Unit>> deleteMessage(
      String receiverID, List<String> messageIDs);

  Future<Either<Failure, Unit>> setPinnedStatus(
      {required String chatID, required String userID, required bool isPinned});

  Future<Either<Failure, Unit>> setMutedStatus(
      {required String chatID, required String userID, required bool isMuted});

  Future<Either<Failure, bool>> isChatMuted(
      {required String chatID, required String userID});

  Stream<Either<Failure, List<MessageEntity>>> getMessages(
    UserEntity currentUser,
    UserEntity otherUser,
    ChatEntity chat,
  );

  Future<Either<Failure, Unit>> deleteChatRoom({
    required String chatRoomID,
    required String receiverUserID,
    required String currentUserID,
  });

  void markChatsAsRead(List<String> chatsIDs, String currentUserID);
}
