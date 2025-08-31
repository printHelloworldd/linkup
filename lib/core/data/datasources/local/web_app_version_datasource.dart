/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/core/data/datasources/local/app_version_datasource.dart';

AppVersionDatasource getInstance() => WebAppVersionDatasource();

class WebAppVersionDatasource implements AppVersionDatasource {
  static const String versionUrl = '/version.json';
  static String currentVersion = "1.12.2";

  WebAppVersionDatasource() {
    _loadCurrentVersion();
  }

  // static Future<void> init() async {
  //   await _loadCurrentVersion();
  // }

  static Future<void> _loadCurrentVersion() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentVersion = data['version'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load app version: $e');
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      // timestamp to prevent query caching
      final response = await http.get(
          Uri.parse('$versionUrl?t=${DateTime.now().millisecondsSinceEpoch}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newVersion = data['version'];

        final Map<String, dynamic> result = {
          "isUpdateAvailable": newVersion != currentVersion ? true : false,
          "currentVersion": currentVersion,
          "newVersion": newVersion,
        };

        return result;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check the updates: $e');
      }
      return null;
    }
  }

  @override
  Future<void> update() async {
    // Disables Service Worker
    if (html.window.navigator.serviceWorker != null) {
      var registrations =
          await html.window.navigator.serviceWorker!.getRegistrations();
      for (var registration in registrations) {
        await registration.unregister();
        if (kDebugMode) {
          print("Service worker was disabled");
        }
      }
    }

    // Clears cache
    if (html.window.caches != null) {
      var cacheNames = await html.window.caches!.keys();
      for (var cacheName in cacheNames) {
        await html.window.caches!.delete(cacheName);
        if (kDebugMode) {
          print("Cache was cleared");
        }
      }
    }

    // Forces page refresh
    html.window.location.reload();
  }
}
