import 'package:linkup/features/Chat/domain/repositories/chat_repository.dart';

class DeleteMessageUc {
  final ChatRepository _repository;

  DeleteMessageUc(this._repository);

  Future<void> call(String receiverID, List<String> messageIDs) async {
    await _repository.deleteMessage(receiverID, messageIDs);
  }
}
