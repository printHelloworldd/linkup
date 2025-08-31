// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUp extends AuthEvent {
  final Completer? completer;
  final String email;
  final String password;

  SignUp({required this.email, required this.password, this.completer});

  @override
  List<Object?> get props => [completer, email, password];
}

class CreateUser extends AuthEvent {
  final String pin;

  CreateUser({required this.pin});
}

class SignIn extends AuthEvent {
  final Completer? completer;
  final String email;
  final String password;

  SignIn({
    required this.email,
    required this.password,
    this.completer,
  });

  @override
  List<Object?> get props => [completer, email, password];
}

class SignInViaGoogle extends AuthEvent {
  final Completer? completer;

  SignInViaGoogle({this.completer});

  @override
  List<Object?> get props => [completer];
}

class SignUpViaGoogle extends AuthEvent {}

class UpdateUserData extends AuthEvent {
  final String? id;
  final String? email;
  final String? fullName;
  final String? age;
  final String? gender;
  final List<HobbyEntity>? hobbies;
  final String? country;
  final String? city;
  final Uint8List? profileImage;
  final String? bio;
  final Map<String, dynamic>? socialMediaLinks;

  UpdateUserData({
    this.id,
    this.email,
    this.fullName,
    this.age,
    this.gender,
    this.hobbies,
    this.country,
    this.city,
    this.profileImage,
    this.bio,
    this.socialMediaLinks,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        age,
        gender,
        hobbies,
        country,
        city,
        profileImage,
        bio,
        socialMediaLinks,
      ];
}

class SignOutEvent extends AuthEvent {}

class InitNotifications extends AuthEvent {
  final String userID;

  InitNotifications({
    required this.userID,
  });
}

class SendPasswordResetEmail extends AuthEvent {
  final String email;

  SendPasswordResetEmail({required this.email});
}

class SendVerificationEmail extends AuthEvent {}

class CheckEmailVerification extends AuthEvent {}

class ReloadCurrentUser extends AuthEvent {}
