// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

class GettingUserState extends ProfileState {}

class GotUserState extends ProfileState {
  final UserEntity? user;
  final bool isCryptoDataEmpty;

  const GotUserState({
    required this.user,
    required this.isCryptoDataEmpty,
  });

  @override
  List<Object?> get props => [user];
}

class GettingUserFailureState extends ProfileState {
  final Object? exception;

  const GettingUserFailureState({
    this.exception,
  });

  @override
  List<Object?> get props => [exception];
}

class UpdatedUserState extends ProfileState {
  final UserEntity user;

  const UpdatedUserState({
    required this.user,
  });

  @override
  List<Object> get props => [user];
}
