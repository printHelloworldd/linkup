// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:linkup/core/domain/repository/firestore_repository.dart';
import 'package:linkup/features/Authentication/domain/repository/firebase_auth_repository.dart';

class CheckUserDataUc {
  final FirestoreRepository firestoreRepository;
  final FirebaseAuthRepository firebaseAuthRepository;

  CheckUserDataUc({
    required this.firestoreRepository,
    required this.firebaseAuthRepository,
  });

  Future<bool> call() async {
    final String? currentUserID = firebaseAuthRepository.getCurrentUserID();

    if (currentUserID == null) return false;

    return firestoreRepository.isUserCreated(currentUserID);
  }
}
