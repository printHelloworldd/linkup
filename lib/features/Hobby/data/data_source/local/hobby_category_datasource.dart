/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A data source for loading hobby categories from a CSV asset file.
///
/// The CSV file is expected to be located at
/// `assets/hobby_dataset/hobbies_with_icons.csv` and to have the following format:
/// ```csv
/// Hobby-name,Type,Icon
/// Reading,Indoor,icon url
/// Hiking,Outdoor,icon url
/// ...
/// ```
///
/// Each row is parsed into a `Map<String, String>` with keys corresponding to
/// the headers: `Hobby-name`, `Type`, and `Icon`.
class HobbyCategoryDatasource {
  final CsvToListConverter csvToListConverter =
      const CsvToListConverter(eol: "\n");

  /// Loads the list of hobbies from the CSV file and returns a list of maps
  /// where each map represents a hobby with keys: `Hobby-name`, `Type`, and `Icon`.
  ///
  /// Returns an empty list if the file is missing or an error occurs during parsing.
  Future<List<Map<String, dynamic>>> getHobbies() async {
    try {
      List<Map<String, String>> hobbies = [];
      final rawData = await rootBundle
          .loadString('assets/hobby_dataset/hobbies_with_icons.csv');

      List<List<dynamic>> csvData = csvToListConverter.convert(rawData);

      if (csvData.isNotEmpty) {
        List<String> headers = csvData[0].map((e) => e.toString()).toList();

        hobbies = csvData.skip(1).map((row) {
          return {
            headers[0]: row[0].toString(), // Hobby-name
            headers[1]: row[1].toString(), // Type
            headers[2]: row[2].toString(), // Icon
          };
        }).toList();
      }

      return hobbies;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load hobbies from csv: $e");
      }

      throw Exception(e.toString());
    }
  }
}
