/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get_it/get_it.dart';
import 'package:linkup/core/domain/usecases/crypto/recover_data_uc.dart';
import 'package:linkup/core/domain/usecases/get_user_uc.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase_to_rdb.dart';
import 'package:linkup/core/domain/usecases/update_user_uc.dart';
import 'package:linkup/core/domain/usecases/check_updates_uc.dart';
import 'package:linkup/core/domain/usecases/update_app_uc.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase.dart';
import 'package:linkup/features/Profile/data/datasources/share_plus_datasource.dart';
import 'package:linkup/features/Profile/data/repository/share_plus_repository_impl.dart';
import 'package:linkup/features/Profile/domain/usecases/share_profile_usecase.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/share_plus/share_plus_bloc.dart';
import 'package:linkup/features/Profile/presentation/bloc/app_version/app_version_bloc.dart';

final sl = GetIt.instance;

Future<void> initProfileFeature() async {
  await _initDatasources();
  await _initRepositories();
  await _initUseCases();
  await _initBlocs();
}

Future<void> _initDatasources() async {
  sl.registerLazySingleton<SharePlusDatasource>(() => SharePlusDatasource());
}

Future<void> _initRepositories() async {
  sl.registerLazySingleton<SharePlusRepositoryImpl>(
    () => SharePlusRepositoryImpl(
      sl<SharePlusDatasource>(),
    ),
  );
}

Future<void> _initUseCases() async {
  sl.registerLazySingleton<ShareProfileUsecase>(
    () => ShareProfileUsecase(
      sl<SharePlusRepositoryImpl>(),
    ),
  );
}

Future<void> _initBlocs() async {
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserUc: sl<GetUserUc>(),
      insertUserUsecase: sl<InsertUserUsecase>(),
      insertUserUsecaseToRdb: sl<InsertUserUsecaseToRdb>(),
      updateUserUc: sl<UpdateUserUc>(),
      recoverDataUc: sl<RecoverDataUc>(),
    ),
  );

  sl.registerFactory<SharePlusBloc>(
    () => SharePlusBloc(
      shareProfileUsecase: sl<ShareProfileUsecase>(),
    ),
  );

  sl.registerFactory<AppVersionBloc>(
    () => AppVersionBloc(
      checkUpdatesUc: sl<CheckUpdatesUc>(),
      updateAppUc: sl<UpdateAppUc>(),
    ),
  );
}
