// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/firestore/get_all_users_usecase.dart';
import 'package:linkup/core/failures/failure.dart';

part 'filter_users_event.dart';
part 'filter_users_state.dart';

class FilterUsersBloc extends Bloc<FilterUsersEvent, FilterUsersState> {
  final GetAllUsersUsecase getAllUsersUsecase;

  List<UserEntity> cachedUsers = [];

  FilterUsersBloc({
    required this.getAllUsersUsecase,
  }) : super(FilterUsersInitial()) {
    on<GetAllUsers>((event, emit) async {
      if (cachedUsers.isEmpty) {
        emit(GettingAllUsers());

        final Either<Failure, List<UserEntity>> usersResult =
            await getAllUsersUsecase();

        usersResult.fold((failure) {
          if (kDebugMode) {
            print("Failed to get all users: ${failure.message}");
          }
          emit(GettingAllUsersFailure(exception: failure));
        }, (users) {
          cachedUsers = users;
          print(users.any((user) => user.restrictedDataEntity != null));

          emit(GotAllUsers(allUsers: users));
        });
      }
    });

    on<SearchUsersEvent>((event, emit) {
      final filteredUsers = cachedUsers
          .where((user) =>
              user.fullName.toLowerCase().contains(event.query.toLowerCase()) ||
              user.id == event.query)
          .toList();

      emit(SearchedUsers(filteredUsers: filteredUsers));
    });
  }
}
