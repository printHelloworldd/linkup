// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';

import 'package:linkup/core/domain/usecases/get_hobby_categories_usecase.dart';
import 'package:linkup/core/failures/failure.dart';

part 'hobby_event.dart';
part 'hobby_state.dart';

class HobbyBloc extends Bloc<HobbyEvent, HobbyState> {
  List<HobbyCategoryEntity>? cachedHobbies;

  HobbyBloc({
    required this.getHobbyCategoriesUsecase,
  }) : super(HobbyInitial()) {
    on<GetHobbies>((event, emit) async {
      try {
        if (cachedHobbies != null) {
          emit(GotHobbies(cachedHobbies!));
          return;
        }
        emit(GettingHobbies());

        final Either<Failure, List<HobbyCategoryEntity>> hobbiesResult =
            await getHobbyCategoriesUsecase();

        hobbiesResult.fold((failure) {
          emit(GettingHobbiesFailure());
        }, (hobbies) {
          cachedHobbies = hobbies;

          emit(GotHobbies(hobbies));
        });
      } finally {
        event.completer?.complete();
      }
    });
  }

  final GetHobbyCategoriesUsecase getHobbyCategoriesUsecase;
}
