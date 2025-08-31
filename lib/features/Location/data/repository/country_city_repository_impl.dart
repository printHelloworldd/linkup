/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/features/Authentication/data/datasource/remote/firebase_auth_datasource.dart';
import 'package:linkup/core/domain/entities/city_entity.dart';
import 'package:linkup/core/domain/entities/country_entity.dart';
import 'package:linkup/core/domain/repository/country_city_repository.dart';
import 'package:linkup/features/Location/data/data_source/remote/country_city_datasource.dart';
import 'package:linkup/features/Location/data/models/city_model.dart';
import 'package:linkup/features/Location/data/models/country_model.dart';

class CountryCityRepositoryImpl implements CountryCityRepository {
  final CountryCityDatasource _countryCityDatasource;
  final FirebaseAuthDatasource _firebaseAuthDatasource;

  CountryCityRepositoryImpl(
      this._countryCityDatasource, this._firebaseAuthDatasource);

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    try {
      // List<CountryModel> countries = await _countryCityDatasource.getCountries();
      final String? idToken = await _firebaseAuthDatasource.getUserIdToken();

      List<Map<String, dynamic>> countries =
          await _countryCityDatasource.getCountries(idToken ?? "");

      final List<CountryEntity> entities = countries
          .map((country) => CountryModel.fromJson(country).toEntity())
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCities(String country) async {
    try {
      // List<CityModel> cities =
      //     await _countryCityDatasource.getCitiesByCountry(country);

      final String? idToken = await _firebaseAuthDatasource.getUserIdToken();

      final List<Map<String, dynamic>> cities = await _countryCityDatasource
          .getCitiesByCountry(countryCode: country, idToken: idToken ?? "");

      final List<CityEntity> entities =
          cities.map((city) => CityModel.fromJson(city).toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(CommonFailure(e.toString()));
    }
  }
}
