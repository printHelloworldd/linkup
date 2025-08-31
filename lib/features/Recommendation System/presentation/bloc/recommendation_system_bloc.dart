import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/features/Recommendation%20System/domain/usecases/get_recommended_users.dart';

part 'recommendation_system_event.dart';
part 'recommendation_system_state.dart';

class RecommendationSystemBloc
    extends Bloc<RecommendationSystemEvent, RecommendationSystemState> {
  final GetRecommendedUsers getRecommendedUsers;

  List<String> sortValues = [];
  List<String> blockedUsers = [];

  RecommendationSystemBloc({
    required this.getRecommendedUsers,
  }) : super(RecommendationSystemInitial()) {
    on<GetRecommendedUsersEvent>((event, emit) async {
      try {
        // print("Cached user: $blockedUsers");
        // print("New user: ${event.user.blockedUsers}");
        // print(
        //     "user == event.user: ${identical(blockedUsers, event.user.blockedUsers)}");

        if (!listEquals(sortValues, event.sortValues) ||
            !listEquals(blockedUsers, event.user.blockedUsers)) {
          emit(GettingRecommendedUsers());
          // print("---");

          final List<UserEntity> users =
              await getRecommendedUsers(event.user, event.sortValues);

          sortValues = event.sortValues;
          blockedUsers.addAll(event.user.blockedUsers
              .where((blockedUser) => !blockedUsers.contains(blockedUser)));

          emit(
            GotRecommendedUsers(
              recommendedUsers: users,
              sortValues: event.sortValues,
            ),
          );
        }
      } catch (e) {
        emit(GettingRecommendedUsersFailure(exception: e));
        if (kDebugMode) {
          print("Failed to get recommended users: $e");
        }
      }
    });
  }
}
