// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_blocking_bloc.dart';

sealed class UserBlockingState extends Equatable {
  const UserBlockingState();

  @override
  List<Object?> get props => [];
}

final class UserBlockingInitial extends UserBlockingState {}

class LoadingBlockedUsers extends UserBlockingState {}

class LoadingBlockedUsersFailure extends UserBlockingState {
  final Object? exception;

  const LoadingBlockedUsersFailure({
    this.exception,
  });

  @override
  List<Object?> get props => [exception];
}

class LoadedBlockedUsers extends UserBlockingState {
  final List<UserEntity> blockedUsers;

  const LoadedBlockedUsers({
    required this.blockedUsers,
  });

  @override
  List<Object> get props => [blockedUsers];
}
