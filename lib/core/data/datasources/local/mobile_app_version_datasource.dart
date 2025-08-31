import 'package:flutter/foundation.dart';
import 'package:linkup/core/data/datasources/local/app_version_datasource.dart';
import 'package:upgrader/upgrader.dart';

AppVersionDatasource getInstance() => MobileAppVersionDatasource();

class MobileAppVersionDatasource implements AppVersionDatasource {
  @override
  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      final upgrader = Upgrader();

      await upgrader.initialize(); // запрос в App Store / Play Store
      final String? storeVersion =
          upgrader.currentAppStoreVersion; // версия в Store
      final String? localVersion = upgrader.currentInstalledVersion; // текущая
      final bool isUpdateAvailable = upgrader.isUpdateAvailable();

      if (kDebugMode) {
        print("Installed: $localVersion, Store: $storeVersion");
        print("Is update available: $isUpdateAvailable");
      }

      return {
        "isUpdateAvailable": storeVersion != localVersion,
        "currentVersion": localVersion,
        "newVersion": storeVersion,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check updates: $e');
      }
      return null;
    }
  }

  @override
  Future<void> update() async {
    // TODO: implement update
    throw UnimplementedError();
  }
}
