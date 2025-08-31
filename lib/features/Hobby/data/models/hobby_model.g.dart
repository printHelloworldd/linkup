// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hobby_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HobbyModel _$HobbyModelFromJson(Map<String, dynamic> json) => HobbyModel(
      hobbyName: json['hobbyName'] as String,
      categoryName: json['categoryName'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$HobbyModelToJson(HobbyModel instance) =>
    <String, dynamic>{
      'hobbyName': instance.hobbyName,
      'categoryName': instance.categoryName,
      'icon': instance.icon,
    };
