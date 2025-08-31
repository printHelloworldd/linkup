/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/core/domain/repository/hobby_category_repository.dart';
import 'package:linkup/core/failures/failure.dart';

class GetHobbyCategoriesUsecase {
  final HobbyCategoryRepository _hobbyCategoryRepository;

  GetHobbyCategoriesUsecase(this._hobbyCategoryRepository);

  Future<Either<Failure, List<HobbyCategoryEntity>>> call() async {
    return await _hobbyCategoryRepository.getHobbyCategories();
  }
}
