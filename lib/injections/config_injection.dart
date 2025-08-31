import 'package:get_it/get_it.dart';
import 'package:linkup/config/theme/cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initConfig() async {
  await _initStateProviders();
}

Future<void> _initStateProviders() async {
  sl.registerFactory<ThemeCubit>(
    () => ThemeCubit(),
  );
}
