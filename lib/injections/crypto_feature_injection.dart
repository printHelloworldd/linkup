import 'package:get_it/get_it.dart';
import 'package:linkup/features/Crypto/data/datasource/crypto_datasource.dart';
import 'package:linkup/features/Crypto/data/reposotory/crypto_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initCryptoFeature() async {
  // DATASOURCES
  await _initDatasources();

  // REPOSITORIES
  await _initRepositories();
}

Future<void> _initDatasources() async {
  sl.registerLazySingleton<CryptoDatasource>(() => CryptoDatasource());
}

Future<void> _initRepositories() async {
  sl.registerLazySingleton<CryptoRepositoryImpl>(
    () => CryptoRepositoryImpl(
      cryptoDatasource: sl<CryptoDatasource>(),
    ),
  );
}
