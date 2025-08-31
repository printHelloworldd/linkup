import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

base class SetPinnedStatusUc {
  final ChatRepository chatRepository;

  SetPinnedStatusUc({required this.chatRepository});

  Future<void> call(
      {required String chatID,
      required String userID,
      required bool isPinned}) async {
    await chatRepository.setPinnedStatus(
        chatID: chatID, userID: userID, isPinned: isPinned);
  }
}
