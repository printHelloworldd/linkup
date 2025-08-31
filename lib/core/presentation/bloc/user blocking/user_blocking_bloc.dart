import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/firestore/block_user_uc.dart';
import 'package:linkup/core/domain/usecases/firestore/get_blocked_users_uc.dart';
import 'package:linkup/core/domain/usecases/firestore/unblock_user_uc.dart';
import 'package:linkup/core/failures/failure.dart';

part 'user_blocking_event.dart';
part 'user_blocking_state.dart';

class UserBlockingBloc extends Bloc<UserBlockingEvent, UserBlockingState> {
  final BlockUserUc blockUserUc;
  final UnblockUserUc unblockUserUc;
  final GetBlockedUsersUc getBlockedUsersUc;

  UserBlockingBloc({
    required this.blockUserUc,
    required this.unblockUserUc,
    required this.getBlockedUsersUc,
  }) : super(UserBlockingInitial()) {
    on<BlockUserEvent>((event, emit) async {
      try {
        await blockUserUc(event.blockUserID, event.currentUserID);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to block the user: $e");
        }
      }
    });

    on<UnblockUserEvent>((event, emit) async {
      try {
        await unblockUserUc(event.blockedUserID, event.currentUserID);

        add(GetBlockedUsersEvent(currentUserID: event.currentUserID));
      } catch (e) {
        if (kDebugMode) {
          print("Failed to unblock the user: $e");
        }
      }
    });

    on<GetBlockedUsersEvent>((event, emit) async {
      emit(LoadingBlockedUsers());

      final Either<Failure, List<UserEntity>> blockedUsersResult =
          await getBlockedUsersUc(event.currentUserID);

      blockedUsersResult.fold((failure) {
        emit(LoadingBlockedUsersFailure(exception: failure));
        if (kDebugMode) {
          print("Failed to load all blocked users: ${failure.message}");
        }
      }, (blockedUsers) {
        emit(LoadedBlockedUsers(blockedUsers: blockedUsers));
      });
    });
  }
}
