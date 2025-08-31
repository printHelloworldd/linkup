/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

abstract class AppVersionRepository {
  Future<void> update();
  Future<Map<String, dynamic>?> checkForUpdates();
}
