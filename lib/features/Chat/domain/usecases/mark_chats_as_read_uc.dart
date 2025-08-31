import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';
import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class MarkChatsAsReadUc {
  final ChatRepository chatRepository;
  final FirebaseAuthRepository firebaseAuthRepository;

  MarkChatsAsReadUc({
    required this.chatRepository,
    required this.firebaseAuthRepository,
  });

  void call(List<String> chatsIDs) {
    final String? userID = firebaseAuthRepository.getCurrentUserID();

    if (userID == null) return;

    chatRepository.markChatsAsRead(chatsIDs, userID);
  }
}
