import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/city_entity.dart';
import 'package:linkup/core/domain/entities/country_entity.dart';
import 'package:linkup/core/domain/usecases/get_cities_usecase.dart';
import 'package:linkup/core/domain/usecases/get_countries_usecase.dart';
import 'package:linkup/core/failures/failure.dart';

part 'country_city_event.dart';
part 'country_city_state.dart';

class CountryCityBloc extends Bloc<CountryCityEvent, CountryCityState> {
  final GetCountriesUsecase getCountriesUsecase;
  final GetCitiesUsecase getCitiesUsecase;

  List<CityEntity> cachedCities = [];
  List<CountryEntity> cachedCountries = [];

  String selectedCountry = "";
  String selectedCity = "";

  CountryCityBloc(
      {required this.getCountriesUsecase, required this.getCitiesUsecase})
      : super(CountryCityInitial()) {
    on<GetCountries>((event, emit) async {
      if (cachedCountries.isNotEmpty) {
        emit(GotCountries(cachedCountries));
        return;
      }

      emit(GettingCountries());

      final Either<Failure, List<CountryEntity>> countriesResult =
          await getCountriesUsecase();

      countriesResult.fold((failure) {
        emit(GetCountriesFailure());
        if (kDebugMode) {
          print("Failed to get countries from API: ${failure.message}");
        }
      }, (countries) {
        cachedCountries = countries;

        emit(GotCountries(countries));
      });
    });

    on<GetCities>((event, emit) async {
      emit(GettingCities());

      final Either<Failure, List<CityEntity>> citiesResult =
          await getCitiesUsecase(event.querry);

      citiesResult.fold((failure) {
        emit(GetCitiesFailure());
        if (kDebugMode) {
          print("Failed to get cities from API: ${failure.message}");
        }
      }, (cities) {
        cachedCities = cities;

        emit(GotCities(cities));
      });
    });
  }
}
