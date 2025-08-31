/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get_it/get_it.dart';
import 'package:linkup/core/data/repository/firestore_repository_impl.dart';
import 'package:linkup/features/Hobby/data/repository/hobby_category_repository_impl.dart';
import 'package:linkup/features/Recommendation%20System/domain/usecases/get_recommended_users.dart';
import 'package:linkup/features/Recommendation%20System/presentation/bloc/recommendation_system_bloc.dart';

final sl = GetIt.instance;

Future<void> initRecSystemFeature() async {
  await _initUseCases();
  await _initBlocs();
}

Future<void> _initUseCases() async {
  sl.registerLazySingleton<GetRecommendedUsers>(
    () => GetRecommendedUsers(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
      hobbyCategoryRepository: sl<HobbyCategoryRepositoryImpl>(),
    ),
  );
}

Future<void> _initBlocs() async {
  sl.registerFactory<RecommendationSystemBloc>(
    () => RecommendationSystemBloc(
      getRecommendedUsers: sl<GetRecommendedUsers>(),
    ),
  );
}
