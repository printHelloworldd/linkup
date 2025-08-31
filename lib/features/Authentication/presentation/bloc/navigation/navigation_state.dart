part of 'navigation_bloc.dart';

// sealed class NavigationState extends Equatable {}
sealed class NavigationState {}

final class NavigationInitial extends NavigationState {
  @override
  List<Object?> get props => [];
}

class NavigatedToNextPage extends NavigationState {
  @override
  List<Object?> get props => [];
}

class OnFinishedUserRegistration extends NavigationState {
  @override
  List<Object?> get props => [];
}
