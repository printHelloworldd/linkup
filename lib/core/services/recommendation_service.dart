import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/hobby_category_entity.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/repository/hobby_category_repository.dart';
import 'package:linkup/core/failures/failure.dart';

class RecommendationService {
  final HobbyCategoryRepository hobbyCategoryRepository;

  RecommendationService({required this.hobbyCategoryRepository});

  Future<List<UserEntity>> recommend({
    required UserEntity user,
    required List<UserEntity> users,
    List<String> sortValues = const ["Worldwide", "None", "None"],
  }) async {
    final Either<Failure, List<HobbyCategoryEntity>> hobbiesResult =
        await hobbyCategoryRepository.getHobbyCategories();

    if (hobbiesResult.isLeft()) return [];

    final List<HobbyCategoryEntity> hobbies = hobbiesResult.getOrElse(() => []);

    List<Map<String, dynamic>> similarUsersData =
        secondModel(user, users, hobbies);
    List<UserEntity> recommendedUsers =
        similarUsersData.map((data) => data["user"] as UserEntity).toList();

    return _filterUsers(user, recommendedUsers, sortValues);
  }

  /// Filters a list of users based on the given sort values:
  /// - Removes blocked users
  /// - Optionally filters by location (country or city)
  /// - Optionally filters by hobby name
  /// - Optionally filters by hobby category
  ///
  /// The [sortValues] list is expected to contain exactly three values:
  /// 1. Location filter (e.g., "Worldwide", country name, or city name)
  /// 2. Hobby name filter (e.g., "None" or specific hobby name)
  /// 3. Category name filter (e.g., "None" or specific category name)
  ///
  /// If a filter value is "Worldwide" or "None", the corresponding filter is skipped.
  ///
  /// The result contains distinct users (duplicates removed).
  ///
  /// - [user]: The current user performing the filtering (used for block list).
  /// - [users]: List of all users to be filtered.
  /// - [sortValues]: A list of 3 filter values (location, hobby, category).
  ///
  /// Returns a filtered list of [UserEntity] objects.
  List<UserEntity> _filterUsers(
      UserEntity user, List<UserEntity> users, List<String> sortValues) {
    List<UserEntity> filteredUsers = List.from(users);

    // remove blocked users
    filteredUsers = _removeBlockedUsers(user, filteredUsers);

    // Filter by location
    if (sortValues[0] != "Worldwide") {
      filteredUsers = filteredUsers
          .where((user) =>
              user.country == sortValues[0] || user.city == sortValues[0])
          .toList();
    }

    // Filter by hobbies
    if (sortValues[1] != "None") {
      filteredUsers = filteredUsers
          .where((user) =>
              user.hobbies.any((hobby) => hobby.hobbyName == sortValues[1]))
          .toList();
    }

    // Filter by categories
    if (sortValues[2] != "None") {
      filteredUsers = filteredUsers
          .where((user) =>
              user.hobbies.any((hobby) => hobby.categoryName == sortValues[2]))
          .toList();
    }

    return filteredUsers.toSet().toList();
  }

  /// Removes users who are in the current user's block list from the given user list.
  ///
  /// - [user]: The current user whose `blockedUsers` list is used.
  /// - [users]: List of users to filter.
  ///
  /// Returns a new list of users excluding those whose IDs are found in the current user's blocked list.
  List<UserEntity> _removeBlockedUsers(
      UserEntity user, List<UserEntity> users) {
    final blockedSet = user.blockedUsers.toSet();

    return users.where((user) => !blockedSet.contains(user.id)).toList();
  }

  /// Calculates similarity scores between the current user and a list of other users
  /// using cosine similarity based on shared hobbies, hobby categories, and age.
  ///
  /// Each user is converted into a one-hot encoded feature vector, and the cosine
  /// similarity between the current user's vector and each other user's vector is computed.
  /// The users are then ranked in descending order of similarity.
  ///
  /// Returns a list of maps, where each map contains:
  /// - `"user"`: the [UserEntity] being compared
  /// - `"hobbies"`: list of hobby names of that user
  /// - `"similarity"`: the similarity score as [double]
  ///
  /// [currentUser] - The user for whom recommendations are being generated.
  /// [otherUsers] - List of potential match users to compare against.
  /// [allCategories] - List of all hobby categories with their associated hobbies.
  List<Map<String, dynamic>> secondModel(UserEntity currentUser,
      List<UserEntity> otherUsers, List<HobbyCategoryEntity> allCategories) {
    List<Map<String, dynamic>> rawData = [];
    List<Map<String, dynamic>> similarUsers = [];

    for (var otherUser in otherUsers) {
      // Make a users vectors
      int currentUserAge = int.tryParse(currentUser.age?.trim() ?? "") ?? 0;
      int otherUserAge = int.tryParse(otherUser.age?.trim() ?? "") ?? 0;

      // If one of the 2 users has not selected age, set age as 0
      // for 2 users, to make angle difference less
      if (currentUserAge == 0 || otherUserAge == 0) {
        currentUserAge = 0;
        otherUserAge = 0;
      }

      final List<HobbyEntity> allHobbies = [];
      allCategories.map((category) => allHobbies.addAll(category.hobbiesList));
      allHobbies.toSet().toList();

      List<double> currentUserVector = _buildUserVector(
        allHobbies: allHobbies,
        user: currentUser,
        userAge: currentUserAge,
        allCategories: allCategories,
      );
      List<double> otherUserVector = _buildUserVector(
        allHobbies: allHobbies,
        user: otherUser,
        userAge: otherUserAge,
        allCategories: allCategories,
      );

      // Compute cosine similarity
      double cSimilarity = _computeCosine(currentUserVector, otherUserVector);

      rawData.add({
        "user": otherUser,
        "hobbies": otherUser.hobbies.map((h) => h.hobbyName).toList(),
        "similarity": cSimilarity,
      });
    }

    rawData.sort((a, b) =>
        (b["similarity"] as double).compareTo(a["similarity"] as double));
    similarUsers = rawData;

    return similarUsers;
  }

  /// Constructs a binary feature vector for a given user based on:
  /// - One-hot encoded hobbies (1 if user has the hobby, 0 otherwise)
  /// - One-hot encoded hobby categories
  /// - User's age (as the final feature)
  ///
  /// This vector is used as input to the cosine similarity calculation.
  ///
  /// [allHobbies] - A flat list of all available [HobbyEntity] items.
  /// [user] - The [UserEntity] to convert into a vector.
  /// [userAge] - Parsed age value of the user (0 if unknown).
  /// [allCategories] - List of all hobby categories used for encoding.
  ///
  /// Returns a list of double representing the feature vector.
  List<double> _buildUserVector({
    required List<HobbyEntity> allHobbies,
    required UserEntity user,
    required int userAge,
    required List<HobbyCategoryEntity> allCategories,
  }) {
    List<double> vector = [];

    for (var hobby in allHobbies) {
      if (user.hobbies.contains(hobby)) {
        vector.add(1);
      } else {
        vector.add(0);
      }
    }

    Set<String> userCategories =
        user.hobbies.map((hobby) => hobby.categoryName).toList().toSet();
    for (var category
        in allCategories.map((category) => category.categoryName).toList()) {
      if (userCategories.contains(category)) {
        vector.add(1);
      } else {
        vector.add(0);
      }
    }

    vector.add(userAge.toDouble());

    return vector;
  }

  /// Computes the cosine similarity between two user feature vectors.
  ///
  /// Cosine similarity is defined as the dot product of the vectors
  /// divided by the product of their Euclidean norms. The result ranges from 0
  /// (completely dissimilar) to 1 (identical direction).
  ///
  /// [currentUserVector] - Feature vector of the current user.
  /// [otherUserVector] - Feature vector of the user being compared.
  ///
  /// Returns the cosine similarity as a [double].
  double _computeCosine(
      List<double> currentUserVector, List<double> otherUserVector) {
    // vector scalar product
    double vcp = List.generate(currentUserVector.length,
            (i) => currentUserVector[i] * otherUserVector[i])
        .reduce((sum, value) => sum + value);

    // Euclidean norm
    double a = sqrt(currentUserVector.fold(0, (sum, x) => sum + x * x));
    double b = sqrt(otherUserVector.fold(0, (sum, x) => sum + x * x));

    // cosine similarity
    double cSimilarity = vcp / (a * b);

    return cSimilarity;
  }
}
