// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_blocking_bloc.dart';

sealed class UserBlockingEvent extends Equatable {
  const UserBlockingEvent();

  @override
  List<Object> get props => [];
}

class BlockUserEvent extends UserBlockingEvent {
  final String currentUserID;
  final String blockUserID;

  const BlockUserEvent({
    required this.currentUserID,
    required this.blockUserID,
  });
}

class UnblockUserEvent extends UserBlockingEvent {
  final String currentUserID;
  final String blockedUserID;

  const UnblockUserEvent({
    required this.currentUserID,
    required this.blockedUserID,
  });
}

class GetBlockedUsersEvent extends UserBlockingEvent {
  final String currentUserID;

  const GetBlockedUsersEvent({
    required this.currentUserID,
  });
}
