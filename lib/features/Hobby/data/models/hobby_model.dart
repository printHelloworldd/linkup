/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';

part 'hobby_model.g.dart';

@JsonSerializable()
class HobbyModel extends HobbyEntity {
  const HobbyModel({
    required super.hobbyName,
    required super.categoryName,
    super.icon,
  });

  factory HobbyModel.fromEntity(HobbyEntity entity) {
    return HobbyModel(
      hobbyName: entity.hobbyName,
      categoryName: entity.categoryName,
      icon: entity.icon,
    );
  }

  HobbyEntity toEntity() {
    return HobbyEntity(
      hobbyName: hobbyName,
      categoryName: categoryName,
      icon: icon,
    );
  }

  factory HobbyModel.fromJson(Map<String, dynamic> json) =>
      _$HobbyModelFromJson(json);

  Map<String, dynamic> toJson() => _$HobbyModelToJson(this);
}
