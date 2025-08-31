// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

// class AuthSigningUp extends AuthState {}

// class AuthSignedUp extends AuthState {}

class AuthSigningUpFailure extends AuthState {
  AuthSigningUpFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}

class AuthSigningIn extends AuthState {}

class AuthSignedIn extends AuthState {}

class AuthSigningInFailure extends AuthState {
  final Object? exception;

  AuthSigningInFailure({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class CreatingUser extends AuthState {}

class CreatedUser extends AuthState {}

class CreatingUserFailure extends AuthState {}

class AuthSigningInViaGoogle extends AuthState {}

class AuthSignedInViaGoogle extends AuthState {}

class AuthSigningInViaGoogleFailure extends AuthState {
  final Object? exception;

  AuthSigningInViaGoogleFailure({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class EmailVerified extends AuthState {}
