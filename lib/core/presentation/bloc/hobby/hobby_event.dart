part of 'hobby_bloc.dart';

abstract class HobbyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetHobbies extends HobbyEvent {
  final Completer? completer;

  GetHobbies({this.completer});

  @override
  List<Object?> get props => [completer];
}
