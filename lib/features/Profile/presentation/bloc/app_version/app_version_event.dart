part of 'app_version_bloc.dart';

sealed class AppVersionEvent {
  const AppVersionEvent();
}

final class CheckForUpdates extends AppVersionEvent {}

final class Update extends AppVersionEvent {}
