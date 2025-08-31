/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkup/controller/messages_controller.dart';
import 'package:linkup/controller/network_controller.dart';
import 'package:linkup/core/data/datasources/local/app_database.dart';
import 'package:linkup/core/data/datasources/local/app_version_datasource.dart';
import 'package:linkup/core/data/datasources/local/image_datasource.dart';
import 'package:linkup/core/data/datasources/local/image_picker_datasource.dart';
import 'package:linkup/core/data/datasources/local/secure_storage_datasource.dart';
import 'package:linkup/core/data/datasources/remote/database_datasource.dart';
import 'package:linkup/core/data/datasources/remote/firebase_messaging_datasource.dart';
import 'package:linkup/core/data/datasources/remote/firestore_datasource.dart';
import 'package:linkup/core/data/datasources/remote/supabase_datasource.dart';
import 'package:linkup/core/data/repository/app_database_repository_impl.dart';
import 'package:linkup/core/data/repository/database_repository_impl.dart';
import 'package:linkup/core/data/repository/firebase_messaging_repository_impl.dart';
import 'package:linkup/core/data/repository/firestore_repository_impl.dart';
import 'package:linkup/core/data/repository/secure_storage_repository_impl.dart';
import 'package:linkup/core/data/repository/supabase_repository_impl.dart';
import 'package:linkup/core/domain/usecases/check_user_data_uc.dart';
import 'package:linkup/core/domain/usecases/insert_user_usecase_to_rdb.dart';
import 'package:linkup/core/data/repository/app_version_repository_impl.dart';
import 'package:linkup/core/domain/usecases/crypto/check_pin_uc.dart';
import 'package:linkup/core/domain/usecases/crypto/decrypt_data_uc.dart';
import 'package:linkup/core/domain/usecases/crypto/generate_data_uc.dart';
import 'package:linkup/core/domain/usecases/crypto/recover_data_uc.dart';
import 'package:linkup/core/domain/usecases/firestore/block_user_uc.dart';
import 'package:linkup/core/domain/usecases/firestore/get_all_users_usecase.dart';
import 'package:linkup/core/domain/usecases/firestore/get_blocked_users_uc.dart';
import 'package:linkup/core/domain/usecases/firestore/unblock_user_uc.dart';
import 'package:linkup/core/domain/usecases/get_user_uc.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/get_user_status_uc.dart';
import 'package:linkup/core/domain/usecases/init_notifications_uc.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/update_user_status_uc.dart';
import 'package:linkup/core/domain/usecases/update_user_uc.dart';
import 'package:linkup/core/domain/usecases/check_updates_uc.dart';
import 'package:linkup/core/domain/usecases/update_app_uc.dart';
import 'package:linkup/core/presentation/bloc/crypto/crypto_bloc.dart';
import 'package:linkup/core/presentation/bloc/image%20picker/image_picker_bloc.dart';
import 'package:linkup/core/presentation/bloc/user%20blocking/user_blocking_bloc.dart';
import 'package:linkup/core/presentation/navigation_service.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';
import 'package:linkup/features/Authentication/data/repository/firebase_auth_repository_impl.dart';
import 'package:linkup/core/data/repository/image_picker_repository_impl.dart';
import 'package:linkup/core/domain/usecases/pick_image_from_gallery_usecase.dart';
import 'package:linkup/features/Crypto/data/reposotory/crypto_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initCore() async {
  await Hive.initFlutter();
  await Hive.openBox("app_database");

  // DATASOURCES
  await _initDatasources();

  // REPOSITORIES
  await _initRepositories();

  // USECASESES
  await _initUsecases();

  // STATE PROVIDERS
  await _initStateProviders();

  // SERVICES
  await _initServices();

  // Controllers
  await _initControllers();
}

Future<void> _initDatasources() async {
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => FirestoreDatasource());
  sl.registerLazySingleton(() => ImagePickerDatasource());
  sl.registerLazySingleton(() => DatabaseDatasource());
  sl.registerLazySingleton(() => SupabaseDatasource());
  sl.registerLazySingleton(() => ImageDatasource());
  sl.registerLazySingleton(() => FirebaseMessagingDatasource());
  sl.registerLazySingleton(() => SecureStorageDatasource());

  sl.registerLazySingleton<AppVersionDatasource>(() => AppVersionDatasource());
}

Future<void> _initRepositories() async {
  sl.registerLazySingleton<AppDatabaseRepositoryImpl>(
      () => AppDatabaseRepositoryImpl(sl<AppDatabase>()));

  sl.registerLazySingleton<SecureStorageRepositoryImpl>(
    () => SecureStorageRepositoryImpl(
      secureStorageDatasource: sl<SecureStorageDatasource>(),
      firebaseAuthDatasource: sl<FirebaseAuthDatasource>(),
    ),
  );

  sl.registerLazySingleton<FirestoreRepositoryImpl>(
    () => FirestoreRepositoryImpl(
      firestoreDatasource: sl<FirestoreDatasource>(),
      firebaseAuthDatasource: sl<FirebaseAuthDatasource>(),
    ),
  );

  sl.registerLazySingleton<SupabaseRepositoryImpl>(
    () => SupabaseRepositoryImpl(
      supabaseDatasource: sl<SupabaseDatasource>(),
    ),
  );

  sl.registerLazySingleton<ImagePickerRepositoryImpl>(
    () => ImagePickerRepositoryImpl(
      sl<ImagePickerDatasource>(),
      sl<ImageDatasource>(),
    ),
  );

  sl.registerLazySingleton<DatabaseRepositoryImpl>(
    () => DatabaseRepositoryImpl(
      sl<DatabaseDatasource>(),
    ),
  );

  sl.registerLazySingleton<FirebaseMessagingRepositoryImpl>(
    () => FirebaseMessagingRepositoryImpl(
      firebaseMessagingDatasource: sl<FirebaseMessagingDatasource>(),
      firestoreDatasource: sl<FirestoreDatasource>(),
      secureStorageDatasource: sl<SecureStorageDatasource>(),
      supabaseDatasource: sl<SupabaseDatasource>(),
      firebaseAuthDatasource: sl<FirebaseAuthDatasource>(),
    ),
  );

  sl.registerLazySingleton<AppVersionRepositoryImpl>(
    () => AppVersionRepositoryImpl(
      appVersionDatasource: sl<AppVersionDatasource>(),
    ),
  );
}

Future<void> _initUsecases() async {
  sl.registerLazySingleton<PickImageFromGalleryUsecase>(
      () => PickImageFromGalleryUsecase(sl<ImagePickerRepositoryImpl>()));

  sl.registerLazySingleton<InsertUserUsecaseToRdb>(
    () => InsertUserUsecaseToRdb(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
      supabaseRepository: sl<SupabaseRepositoryImpl>(),
      secureStorageRepository: sl<SecureStorageRepositoryImpl>(),
      cryptoRepository: sl<CryptoRepositoryImpl>(),
      firebaseMessagingRepository: sl<FirebaseMessagingRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<GetAllUsersUsecase>(
    () => GetAllUsersUsecase(
      sl<FirestoreRepositoryImpl>(),
      sl<SupabaseRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<UpdateUserStatusUc>(
    () => UpdateUserStatusUc(
      sl<DatabaseRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<GetUserStatusUc>(
    () => GetUserStatusUc(
      sl<DatabaseRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<InitNotificationsUc>(
    () => InitNotificationsUc(
      sl<FirebaseMessagingRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<GetUserUc>(
    () => GetUserUc(
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>(),
      secureStorageRepository: sl<SecureStorageRepositoryImpl>(),
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
      supabaseRepository: sl<SupabaseRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<UpdateUserUc>(
    () => UpdateUserUc(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
      supabaseRepository: sl<SupabaseRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<BlockUserUc>(
    () => BlockUserUc(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<UnblockUserUc>(
    () => UnblockUserUc(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<GetBlockedUsersUc>(
    () => GetBlockedUsersUc(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<CheckUpdatesUc>(
    () => CheckUpdatesUc(
      appVersionRepository: sl<AppVersionRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<UpdateAppUc>(
    () => UpdateAppUc(
      appVersionRepository: sl<AppVersionRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<DecryptDataUc>(
    () => DecryptDataUc(
      cryptoRepository: sl<CryptoRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<CheckPinUc>(
    () => CheckPinUc(
      cryptoRepository: sl<CryptoRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<GenerateDataUc>(
    () => GenerateDataUc(
      cryptoRepository: sl<CryptoRepositoryImpl>(),
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<RecoverDataUc>(
    () => RecoverDataUc(
      cryptoRepository: sl<CryptoRepositoryImpl>(),
      secureStorageRepository: sl<SecureStorageRepositoryImpl>(),
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<CheckUserDataUc>(
    () => CheckUserDataUc(
      firestoreRepository: sl<FirestoreRepositoryImpl>(),
      firebaseAuthRepository: sl<FirebaseAuthRepositoryImpl>(),
    ),
  );
}

Future<void> _initStateProviders() async {
  sl.registerFactory<ImagePickerBloc>(
    () => ImagePickerBloc(
      pickImageFromGalleryUsecase: sl<PickImageFromGalleryUsecase>(),
    ),
  );

  sl.registerFactory<UserBlockingBloc>(
    () => UserBlockingBloc(
      blockUserUc: sl<BlockUserUc>(),
      unblockUserUc: sl<UnblockUserUc>(),
      getBlockedUsersUc: sl<GetBlockedUsersUc>(),
    ),
  );

  sl.registerFactory<CryptoBloc>(
    () => CryptoBloc(
      decryptDataUc: sl<DecryptDataUc>(),
      checkPinUc: sl<CheckPinUc>(),
      generateDataUc: sl<GenerateDataUc>(),
    ),
  );
}

Future<void> _initServices() async {
  sl.registerLazySingleton(() => NavigationService());
}

Future<void> _initControllers() async {
  Get.put<NetworkController>(NetworkController(), permanent: true);
  Get.put<MessagesController>(MessagesController(), permanent: true);
}
