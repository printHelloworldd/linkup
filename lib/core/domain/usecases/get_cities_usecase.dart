/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/city_entity.dart';
import 'package:linkup/core/domain/repository/country_city_repository.dart';
import 'package:linkup/core/failures/failure.dart';

class GetCitiesUsecase {
  final CountryCityRepository _countryCityRepository;

  GetCitiesUsecase(this._countryCityRepository);

  Future<Either<Failure, List<CityEntity>>> call(String country) async {
    return await _countryCityRepository.getCities(country);
  }
}
