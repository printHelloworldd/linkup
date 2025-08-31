/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/data/datasources/local/app_database.dart';
import 'package:linkup/core/data/models/user/user_model.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/app_database_repository.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';

class AppDatabaseRepositoryImpl implements AppDatabaseRepository {
  final AppDatabase _appDatabase;

  AppDatabaseRepositoryImpl(this._appDatabase);

  @override
  Future<void> insertUserToHive(UserEntity user) async {
    UserModel userModel = UserModel.fromEntity(user);

    // Convert List<HobbyModel> => List<Map<String, dynamic>>
    List<Map<String, dynamic>> formattedHobbies =
        userModel.hobbies.map((hobby) {
      return {
        "name": hobby.hobbyName,
        "category": hobby.categoryName,
        // "icons": hobby.iconsList,
      };
    }).toList();

    // Convert UserModel => Map<String, dynamic>
    Map<String, dynamic> userData =
        userModel.toJson(includeSensitiveData: true);
    userData["hobbies"] = formattedHobbies; // Update a list of hobbies
  }

  @override
  Future<UserEntity?> getUserFromHive() async {
    final Map<dynamic, dynamic>? returnedData = await _appDatabase.getUser();

    if (returnedData == null) return null;

    Map<String, dynamic> userData = returnedData.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    Map<dynamic, dynamic> rawLinks = userData["socialMediaLinks"] ?? {};
    Map<String, dynamic> formattedLinks = rawLinks.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );

    // Convert List<Map<String, dynamic>> => List<HobbyEntity>
    List<HobbyEntity> formattedHobbies = [];
    for (var hobby in userData["hobbies"]) {
      formattedHobbies.add(
        HobbyEntity(
          hobbyName: hobby["name"],
          categoryName: hobby["category"],
          // iconsList: hobby["icons"],
        ),
      );
    }
    userData["hobbies"] = formattedHobbies;
    userData["socialMediaLinks"] = formattedLinks;

    final userModel = UserModel.fromJson(userData);

    return userModel.toEntity();
  }
}
