part of 'country_city_bloc.dart';

abstract class CountryCityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CountryCityInitial extends CountryCityState {}

class GettingCountries extends CountryCityState {}

class GotCountries extends CountryCityState {
  final List<CountryEntity> countries;

  GotCountries(this.countries);

  @override
  List<Object?> get props => [countries];
}

class GetCountriesFailure extends CountryCityState {}

class GettingCities extends CountryCityState {}

class GotCities extends CountryCityState {
  final List<CityEntity> cities;

  GotCities(this.cities);

  @override
  List<Object?> get props => [cities];
}

class GetCitiesFailure extends CountryCityState {}
