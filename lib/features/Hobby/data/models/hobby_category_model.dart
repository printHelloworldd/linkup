/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/features/Hobby/data/models/hobby_model.dart';

class HobbyCategoryModel extends HobbyCategoryEntity {
  const HobbyCategoryModel({
    required super.categoryName,
    required super.hobbiesList,
  });

  factory HobbyCategoryModel.fromEntity(HobbyCategoryEntity entity) {
    return HobbyCategoryModel(
      categoryName: entity.categoryName,
      hobbiesList: entity.hobbiesList
          .map((hobby) => HobbyModel.fromEntity(hobby))
          .toList(),
    );
  }

  HobbyCategoryEntity toEntity() {
    return HobbyCategoryEntity(
      categoryName: categoryName,
      hobbiesList: List<HobbyModel>.from(hobbiesList)
          .map((HobbyModel hobby) => hobby.toEntity())
          .toList(),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "categoryName": categoryName,
  //     "hobbiesList": hobbiesList.map((hobby) => HobbyModel.toJson()),
  //     "Icon": icon,
  //   };
  // }

  factory HobbyCategoryModel.fromJson(Map<String, dynamic> map) {
    return HobbyCategoryModel(
      categoryName: map["Type"],
      hobbiesList: map["hobbiesList"],
    );
  }
}
