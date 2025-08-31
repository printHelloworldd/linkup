// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'share_plus_bloc.dart';

sealed class SharePlusEvent extends Equatable {
  const SharePlusEvent();

  @override
  List<Object> get props => [];
}

class ShareProfileEvent extends SharePlusEvent {
  final UserEntity user;

  const ShareProfileEvent({
    required this.user,
  });
}
