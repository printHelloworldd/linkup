part of 'share_plus_bloc.dart';

sealed class SharePlusState extends Equatable {
  const SharePlusState();

  @override
  List<Object> get props => [];
}

final class SharePlusInitial extends SharePlusState {}

class SharingProfileDismissed extends SharePlusState {}

class SharingProfileSuccess extends SharePlusState {}

class SharingProfileFailure extends SharePlusState {}
