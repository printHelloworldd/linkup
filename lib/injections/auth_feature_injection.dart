/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get_it/get_it.dart';
import 'package:linkup/core/data/repository/app_database_repository_impl.dart';
import 'package:linkup/core/data/repository/firestore_repository_impl.dart';
import 'package:linkup/core/data/repository/secure_storage_repository_impl.dart';
import 'package:linkup/core/domain/usecases/init_notifications_uc.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase_to_rdb.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';
import 'package:linkup/features/Crypto/data/reposotory/crypto_repository_impl.dart';
import 'package:linkup/features/Authentication/data/repository/firebase_auth_repository_impl.dart';
import 'package:linkup/core/domain/usecases/get_cities_usecase.dart';
import 'package:linkup/core/domain/usecases/get_countries_usecase.dart';
import 'package:linkup/core/domain/usecases/get_hobby_categories_usecase.dart';
import 'package:linkup/features/Authentication/domain/usecases/check_email_verification_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/get_current_user_email_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/google_sign_in_usecase.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase.dart';
import 'package:linkup/features/Authentication/domain/usecases/reload_current_user_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/send_psw_reset_email.dart';
import 'package:linkup/features/Authentication/domain/usecases/send_verification_email_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/sign_in_usercase.dart';
import 'package:linkup/features/Authentication/domain/usecases/sign_out_uc.dart';
import 'package:linkup/features/Authentication/domain/usecases/sign_up_usercase.dart';
import 'package:linkup/features/Authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:linkup/core/presentation/bloc/country_city/country_city_bloc.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_bloc.dart';
import 'package:linkup/core/presentation/bloc/hobby/hobby_selection_cubit.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:linkup/features/Hobby/data/data_source/local/hobby_category_datasource.dart';
import 'package:linkup/features/Hobby/data/repository/hobby_category_repository_impl.dart';
import 'package:linkup/features/Location/data/data_source/remote/country_city_datasource.dart';
import 'package:linkup/features/Location/data/repository/country_city_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initAuthFeature() async {
  await _initDatasources();
  await _initRepositories();
  await _initUseCases();
  await _initBlocs();
}

Future<void> _initDatasources() async {
  sl.registerLazySingleton<FirebaseAuthDatasource>(
      () => FirebaseAuthDatasource());

  sl.registerLazySingleton<HobbyCategoryDatasource>(
      () => HobbyCategoryDatasource());

  // sl.registerLazySingleton<CountryCityDatasource>(
  //     () => CountryCityDatasource.create(apiKey: apiKey, apiUrl: apiUrl));
  sl.registerLazySingleton<CountryCityDatasource>(
      () => CountryCityDatasource());
}

Future<void> _initRepositories() async {
  sl.registerLazySingleton<FirebaseAuthRepositoryImpl>(
    () => FirebaseAuthRepositoryImpl(
      sl<FirebaseAuthDatasource>(),
    ),
  );

  sl.registerLazySingleton<HobbyCategoryRepositoryImpl>(
    () => HobbyCategoryRepositoryImpl(
      sl<HobbyCategoryDatasource>(),
    ),
  );

  sl.registerLazySingleton<CountryCityRepositoryImpl>(
    () => CountryCityRepositoryImpl(
      sl<CountryCityDatasource>(),
      sl<FirebaseAuthDatasource>(),
    ),
  );
}

Future<void> _initUseCases() async {
  sl.registerLazySingleton<SignUpUsercase>(
    () => SignUpUsercase(
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>(),
      cryptoRepository: sl<CryptoRepositoryImpl>(),
      secureStorageRepository: sl<SecureStorageRepositoryImpl>(),
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<SignInUsercase>(
      () => SignInUsercase(sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<GoogleSignInUsecase>(
      () => GoogleSignInUsecase(sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<GetHobbyCategoriesUsecase>(
      () => GetHobbyCategoriesUsecase(sl<HobbyCategoryRepositoryImpl>()));

  sl.registerLazySingleton<GetCountriesUsecase>(
      () => GetCountriesUsecase(sl<CountryCityRepositoryImpl>()));

  sl.registerLazySingleton<GetCitiesUsecase>(
      () => GetCitiesUsecase(sl<CountryCityRepositoryImpl>()));

  sl.registerLazySingleton<InsertUserUsecase>(
      () => InsertUserUsecase(sl<AppDatabaseRepositoryImpl>()));

  sl.registerLazySingleton<SignOutUc>(
      () => SignOutUc(sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<CheckEmailVerificationUc>(() =>
      CheckEmailVerificationUc(
          firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<GetCurrentUserEmailUc>(() => GetCurrentUserEmailUc(
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<ReloadCurrentUserUc>(() => ReloadCurrentUserUc(
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<SendPswResetEmail>(() => SendPswResetEmail(
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>()));

  sl.registerLazySingleton<SendVerificationEmailUC>(() =>
      SendVerificationEmailUC(
          firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>()));
}

Future<void> _initBlocs() async {
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signUpUsercase: sl<SignUpUsercase>(),
      signInUsercase: sl<SignInUsercase>(),
      googleSignInUsecase: sl<GoogleSignInUsecase>(),
      insertUserUsecase: sl<InsertUserUsecase>(),
      insertUserUsecaseToRdb: sl<InsertUserUsecaseToRdb>(),
      initNotificationsUc: sl<InitNotificationsUc>(),
      checkEmailVerificationUc: sl<CheckEmailVerificationUc>(),
      sendPswResetEmail: sl<SendPswResetEmail>(),
      sendVerificationEmailUC: sl<SendVerificationEmailUC>(),
      reloadCurrentUserUc: sl<ReloadCurrentUserUc>(),
      signOutUc: sl<SignOutUc>(),
    ),
  );

  sl.registerFactory<HobbyBloc>(
    () => HobbyBloc(
      getHobbyCategoriesUsecase: sl<GetHobbyCategoriesUsecase>(),
    ),
  );

  sl.registerFactory<CountryCityBloc>(
    () => CountryCityBloc(
      getCountriesUsecase: sl<GetCountriesUsecase>(),
      getCitiesUsecase: sl<GetCitiesUsecase>(),
    ),
  );

  sl.registerFactory<HobbySelectionCubit>(() => HobbySelectionCubit());

  sl.registerFactory<NavigationBloc>(() => NavigationBloc());
}
