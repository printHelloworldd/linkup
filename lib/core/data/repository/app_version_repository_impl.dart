/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/data/datasources/local/app_version_datasource.dart';
import 'package:linkup/core/domain/repository/app_version_repository.dart';

final class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionDatasource appVersionDatasource;

  AppVersionRepositoryImpl({required this.appVersionDatasource});

  @override
  Future<Map<String, dynamic>?> checkForUpdates() async {
    return await appVersionDatasource.checkForUpdates();
  }

  @override
  Future<void> update() async {
    await appVersionDatasource.update();
  }
}
