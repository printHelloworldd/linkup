// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'recommendation_system_bloc.dart';

sealed class RecommendationSystemState extends Equatable {
  const RecommendationSystemState();

  @override
  List<Object?> get props => [];
}

final class RecommendationSystemInitial extends RecommendationSystemState {}

class GettingRecommendedUsers extends RecommendationSystemState {}

class GotRecommendedUsers extends RecommendationSystemState {
  final List<UserEntity> recommendedUsers;
  final List<String> sortValues;

  const GotRecommendedUsers({
    required this.recommendedUsers,
    required this.sortValues,
  });

  @override
  List<Object> get props => [recommendedUsers, sortValues];
}

class GettingRecommendedUsersFailure extends RecommendationSystemState {
  final Object? exception;

  const GettingRecommendedUsersFailure({
    this.exception,
  });

  @override
  List<Object?> get props => [exception];
}
