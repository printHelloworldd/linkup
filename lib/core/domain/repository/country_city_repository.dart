/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/city_entity.dart';
import 'package:linkup/core/domain/entities/country_entity.dart';
import 'package:linkup/core/failures/failure.dart';

abstract class CountryCityRepository {
  Future<Either<Failure, List<CountryEntity>>> getCountries();
  Future<Either<Failure, List<CityEntity>>> getCities(String country);
}
