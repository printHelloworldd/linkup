/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:linkup/core/domain/entities/country_entity.dart';
part 'country_model.g.dart';

@JsonSerializable()
class CountryModel extends CountryEntity {
  const CountryModel({
    required super.name,
    required super.iso2,
    super.native,
    super.emoji,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      _$CountryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CountryModelToJson(this);

  factory CountryModel.fromEntity(CountryEntity entity) {
    return CountryModel(
      name: entity.name,
      iso2: entity.iso2,
      native: entity.native,
      emoji: entity.emoji,
    );
  }

  CountryEntity toEntity() {
    return CountryEntity(
      name: name,
      iso2: iso2,
      native: native ?? "",
      emoji: emoji ?? "",
    );
  }
}
