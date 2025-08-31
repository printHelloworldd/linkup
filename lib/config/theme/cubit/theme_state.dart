part of 'theme_cubit.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class ThemeInitial extends ThemeState {}

final class SetTheme extends ThemeState {
  final ThemeData theme;

  const SetTheme({required this.theme});

  @override
  List<Object> get props => [theme];
}
