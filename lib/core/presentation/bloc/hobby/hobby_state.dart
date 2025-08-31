part of 'hobby_bloc.dart';

abstract class HobbyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HobbyInitial extends HobbyState {}

class GettingHobbiesFailure extends HobbyState {}

class GettingHobbies extends HobbyState {}

class GotHobbies extends HobbyState {
  final List<HobbyCategoryEntity> hobbies;

  GotHobbies(this.hobbies);

  @override
  List<Object?> get props => [hobbies];
}
