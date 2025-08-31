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
import 'package:linkup/features/Hobby/data/data_source/local/hobby_category_datasource.dart';
import 'package:linkup/features/Hobby/data/models/hobby_category_model.dart';
import 'package:linkup/features/Hobby/data/models/hobby_model.dart';

class HobbyCategoryRepositoryImpl implements HobbyCategoryRepository {
  final HobbyCategoryDatasource _hobbyCategoryDatasource;

  HobbyCategoryRepositoryImpl(this._hobbyCategoryDatasource);

  @override
  Future<Either<Failure, List<HobbyCategoryEntity>>>
      getHobbyCategories() async {
    try {
      // List<HobbyCategoryModel> models =
      //     await _hobbyCategoryDatasource.getHobbies();
      // return models.map((model) => model.toEntity()).toList();
      final List<Map<String, dynamic>> hobbies =
          await _hobbyCategoryDatasource.getHobbies();

      Map<String, List<HobbyModel>> groupedHobbies = {};

      for (var hobby in hobbies) {
        String categoryName = hobby["Type"] ?? "Unknown";
        HobbyModel hobbyModel = HobbyModel(
          hobbyName: hobby["Hobby-name"] ?? "Unknown",
          categoryName: categoryName,
          icon: hobby["Icon"] ?? "",
        );

        if (!groupedHobbies.containsKey(categoryName)) {
          groupedHobbies[categoryName] = [];
        }

        groupedHobbies[categoryName]?.add(hobbyModel);
      }

      List<HobbyCategoryModel> hobbyCategoryModels =
          groupedHobbies.entries.map((entry) {
        return HobbyCategoryModel(
          categoryName: entry.key,
          hobbiesList: entry.value,
        );
      }).toList();

      final List<HobbyCategoryEntity> entities =
          hobbyCategoryModels.map((model) => model.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }
}
