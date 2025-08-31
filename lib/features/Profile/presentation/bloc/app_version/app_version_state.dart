part of 'app_version_bloc.dart';

sealed class AppVersionState {
  const AppVersionState();
}

final class AppVersionInitial extends AppVersionState {}

final class UpdateIsAvailable extends AppVersionState {
  final String newVersion;

  const UpdateIsAvailable({required this.newVersion});
}

final class UpdatesIsNotAvailable extends AppVersionState {}

final class UpdateCheckingFailure extends AppVersionState {}
