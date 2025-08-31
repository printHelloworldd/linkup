abstract class Failure {
  final String? message;

  Failure(this.message);
}

class CommonFailure extends Failure {
  CommonFailure(super.message);
}

class FirebaseAuthFailure extends Failure {
  FirebaseAuthFailure(super.message);
}
