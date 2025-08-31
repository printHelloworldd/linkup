import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<NavigateToNextPage>((event, emit) {
      try {
        emit(NavigatedToNextPage());
      } catch (e) {
        if (kDebugMode) {
          print("Failed to navigate to next page!");
        }
      }
    });

    on<OnFinishUserRegistration>((event, emit) async {
      try {
        emit(OnFinishedUserRegistration());
      } catch (e) {
        if (kDebugMode) {
          print("Failed to insert the user");
        }
      }
    });
  }
}
