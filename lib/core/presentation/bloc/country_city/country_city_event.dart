part of 'country_city_bloc.dart';

abstract class CountryCityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetCountries extends CountryCityEvent {}

class GetCities extends CountryCityEvent {
  final String querry;

  GetCities({required this.querry});

  @override
  List<Object?> get props => [querry];
}
