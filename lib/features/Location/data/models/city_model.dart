/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/core/domain/entities/city_entity.dart';
part 'city_model.g.dart';

@JsonSerializable()
class CityModel extends CityEntity {
  const CityModel({
    required super.name,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);
  Map<String, dynamic> toJson() => _$CityModelToJson(this);

  factory CityModel.fromEntity(CityEntity entity) {
    return CityModel(
      name: entity.name,
    );
  }

  CityEntity toEntity() {
    return CityEntity(
      name: name,
    );
  }
}
