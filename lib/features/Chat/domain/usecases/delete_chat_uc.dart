// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class DeleteChatUc {
  final ChatRepository chatRepository;

  DeleteChatUc({
    required this.chatRepository,
  });

  Future<void> call({
    required String chatRoomID,
    required String receiverUserID,
    required String currentUserID,
  }) async {
    await chatRepository.deleteChatRoom(
        chatRoomID: chatRoomID,
        receiverUserID: receiverUserID,
        currentUserID: currentUserID);
  }
}
