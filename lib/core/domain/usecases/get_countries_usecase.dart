/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:dartz/dartz.dart';
import 'package:linkup/core/domain/entities/country_entity.dart';
import 'package:linkup/core/domain/repository/country_city_repository.dart';
import 'package:linkup/core/failures/failure.dart';

class GetCountriesUsecase {
  final CountryCityRepository _countryCityRepository;

  GetCountriesUsecase(this._countryCityRepository);

  Future<Either<Failure, List<CountryEntity>>> call() async {
    return await _countryCityRepository.getCountries();
  }
}
