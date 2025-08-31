import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/services/recommendation_service.dart';
import 'package:linkup/features/Hobby/data/data_source/local/hobby_category_datasource.dart';
import 'package:linkup/features/Hobby/data/models/hobby_category_model.dart';
import 'package:linkup/features/Hobby/data/models/hobby_model.dart';
import 'package:linkup/features/Hobby/data/repository/hobby_category_repository_impl.dart';

class RecommendationFeatureTest {
  final Random random = Random();
  final HobbyCategoryDatasource hobbyCategoryDatasource =
      HobbyCategoryDatasource();

  RecommendationFeatureTest() {
    main();
  }

  void main() {
    _testRecommendationFeature();
  }

  void _testRecommendationFeature() {
    test('Testing method that returns related users with common hobbies',
        () async {
      // Setup
      final RecommendationService recommendationService = RecommendationService(
        hobbyCategoryRepository:
            HobbyCategoryRepositoryImpl(HobbyCategoryDatasource()),
      );

      const UserEntity currentUser = UserEntity(
        id: "id",
        email: "email",
        fullName: "fullName",
        hobbies: [
          HobbyEntity(
            hobbyName: "Powerlifting",
            categoryName: "Outdoors and sports",
          ),
        ],
        blockedUsers: [],
      );

      const List<String> sortValues = ["Worldwide", "None", "None"];

      final List<Map<String, dynamic>> rawHobbies =
          await hobbyCategoryDatasource.getHobbies();

      Map<String, List<HobbyModel>> groupedHobbies = {};

      for (var hobby in rawHobbies) {
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

      final List<HobbyEntity> hobbies = [];
      for (var entity in entities) {
        hobbies.addAll(entity.hobbiesList);
      }
      hobbies.toSet().toList();

      final List<UserEntity> users = generateOtherUsersData(hobbies);

      // Do
      final List<UserEntity> recommendedUsers = await recommendationService
          .recommend(user: currentUser, sortValues: sortValues, users: users);

      // Test
      print("Recommended user hobbies: ${recommendedUsers.first.hobbies}");
      print("Current user hobbies: ${currentUser.hobbies}");

      final bool related = recommendedUsers.first.hobbies.any((hobby) =>
          currentUser.hobbies.contains(hobby) ||
          currentUser.hobbies
              .any((hobby2) => hobby2.categoryName == hobby.categoryName));

      expect(related, true);
    });
  }

  List<HobbyEntity> generateHobbies(List<HobbyEntity> allHobbies) {
    int randomHobbiesQuantity = random.nextInt(6) + 1;
    List<HobbyEntity> hobbies = [];

    for (var i = 0; i < randomHobbiesQuantity; i++) {
      int randomIndex = random.nextInt(allHobbies.length);
      // currentUser.hobbies.add(allHobbies[randomIndex]);

      hobbies.add(allHobbies[randomIndex]);
    }

    return hobbies.toSet().toList();
  }

// Generate other users data
  List<UserEntity> generateOtherUsersData(List<HobbyEntity> allHobbies) {
    List<UserEntity> otherUsers = [];
    final genders = ["-", "Male", "Female"];
    final List<String> countries = [
      "Estonia",
      "Ukraine",
      "France",
      "Germany",
      "Poland",
      "Italy",
      "Great Britain",
    ];

    final List<String> cities = [
      "Tallinn",
      "Kyiv",
      "Paris",
      "Berlin",
      "Warsaw",
      "Rome",
      "London",
    ];

    for (var i = 0; i < 1000; i++) {
      int randomAge = random.nextInt(6) + 16;
      int randomGenderIndex = random.nextInt(3);
      List<HobbyEntity> hobbies = generateHobbies(allHobbies);
      int randomLocationIndex = random.nextInt(countries.length);

      otherUsers.add(
        UserEntity(
          id: "",
          email: "",
          fullName: "User-$i",
          age: randomAge.toString(),
          gender: genders[randomGenderIndex],
          hobbies: hobbies,
          country: countries[randomLocationIndex],
          city: cities[randomLocationIndex],
          bio: "",
          socialMediaLinks: const {},
          blockedUsers: const [],
        ),
      );
    }

    return otherUsers;
  }
}
