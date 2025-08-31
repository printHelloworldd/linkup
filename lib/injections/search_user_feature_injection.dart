/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:get_it/get_it.dart';
import 'package:linkup/core/domain/usecases/firestore/get_all_users_usecase.dart';
import 'package:linkup/features/Search%20User/presentation/bloc/filter_users_bloc.dart';

final sl = GetIt.instance;

Future<void> initSearchUserFeature() async {
  await _initBlocs();
}

Future<void> _initBlocs() async {
  sl.registerFactory<FilterUsersBloc>(
    () => FilterUsersBloc(
      getAllUsersUsecase: sl<GetAllUsersUsecase>(),
    ),
  );
}
