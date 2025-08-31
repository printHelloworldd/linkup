// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'recommendation_system_bloc.dart';

sealed class RecommendationSystemEvent extends Equatable {
  const RecommendationSystemEvent();

  @override
  List<Object> get props => [];
}

class GetRecommendedUsersEvent extends RecommendationSystemEvent {
  final UserEntity user;
  final List<String> sortValues;

  const GetRecommendedUsersEvent({
    required this.user,
    required this.sortValues,
  });
}
