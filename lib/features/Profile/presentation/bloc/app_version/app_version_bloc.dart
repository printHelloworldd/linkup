import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/usecases/check_updates_uc.dart';
import 'package:linkup/core/domain/usecases/update_app_uc.dart';

part 'app_version_event.dart';
part 'app_version_state.dart';

class AppVersionBloc extends Bloc<AppVersionEvent, AppVersionState> {
  final CheckUpdatesUc checkUpdatesUc;
  final UpdateAppUc updateAppUc;

  String? appVersion;

  AppVersionBloc({
    required this.checkUpdatesUc,
    required this.updateAppUc,
  }) : super(AppVersionInitial()) {
    on<CheckForUpdates>((event, emit) async {
      final Map<String, dynamic>? result = await checkUpdatesUc();

      if (result != null) {
        appVersion = result["currentVersion"];

        if (result["isUpdateAvailable"] == true) {
          emit(UpdateIsAvailable(newVersion: result["newVersion"]));
        } else {
          emit(UpdatesIsNotAvailable());
        }
      } else {
        emit(UpdateCheckingFailure());
        if (kDebugMode) {
          print("Failed to check for updates");
        }
      }
    });

    on<Update>((event, emit) async {
      await updateAppUc();

      // TODO: add emit to show user dialog that he's up to date
    });
  }
}
