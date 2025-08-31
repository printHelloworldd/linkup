import 'package:linkup/core/data/datasources/local/app_version_helper.dart'
    if (dart.library.js) 'package:linkup/core/data/datasources/local/web_app_version_datasource.dart'
    if (dart.library.io) 'package:linkup/core/data/datasources/local/mobile_app_version_datasource.dart';

abstract class AppVersionDatasource {
  factory AppVersionDatasource() => getInstance();

  Future<Map<String, dynamic>?> checkForUpdates();
  Future<void> update();
}
