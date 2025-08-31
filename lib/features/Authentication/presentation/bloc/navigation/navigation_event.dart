part of 'navigation_bloc.dart';

sealed class NavigationEvent {}

class NavigateToNextPage extends NavigationEvent {}

class OnFinishUserRegistration extends NavigationEvent {}
