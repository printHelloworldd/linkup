/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:linkup/core/domain/repository/app_version_repository.dart';

base class CheckUpdatesUc {
  final AppVersionRepository appVersionRepository;

  CheckUpdatesUc({required this.appVersionRepository});

  Future<Map<String, dynamic>?> call() async {
    return await appVersionRepository.checkForUpdates();
  }
}
