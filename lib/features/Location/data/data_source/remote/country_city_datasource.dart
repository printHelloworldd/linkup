/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:convert';
import 'package:http/http.dart' as http;

class CountryCityDatasource {
  Future<List<Map<String, dynamic>>> getCountries(String idToken) async {
    try {
      final uri = Uri.parse(
          "https://wpvcdltgljcvclyeuhmv.supabase.co/functions/v1/get_countries");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> rawList = jsonBody['data'];

        final countries = rawList.cast<Map<String, dynamic>>();
        return countries;
      } else {
        throw Exception(
            'Failed to load countries: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getCitiesByCountry(
      {required String countryCode, required String idToken}) async {
    try {
      final uri = Uri.parse(
          "https://wpvcdltgljcvclyeuhmv.supabase.co/functions/v1/get_cities?country=$countryCode");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> rawList = jsonBody['data'];

        final cities = rawList.cast<Map<String, dynamic>>();
        return cities;
      } else {
        throw Exception(
            'Failed to load countries: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
