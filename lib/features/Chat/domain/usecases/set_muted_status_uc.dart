import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

base class SetMutedStatusUc {
  final ChatRepository chatRepository;

  SetMutedStatusUc({required this.chatRepository});

  Future<void> call(
      {required String chatID,
      required String userID,
      required bool isMuted}) async {
    await chatRepository.setMutedStatus(
        chatID: chatID, userID: userID, isMuted: isMuted);
  }
}
