// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryModel _$CountryModelFromJson(Map<String, dynamic> json) => CountryModel(
      name: json['name'] as String,
      iso2: json['iso2'] as String,
      native: json['native'] as String?,
      emoji: json['emoji'] as String?,
    );

Map<String, dynamic> _$CountryModelToJson(CountryModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'iso2': instance.iso2,
      'native': instance.native,
      'emoji': instance.emoji,
    };
