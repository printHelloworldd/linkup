import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/Authentication/presentation/bloc/navigation/navigation_bloc.dart';

class NavigationBlocTest {
  NavigationBlocTest() {
    _testNavigationBloc();
  }

  static void _testNavigationBloc() {
    group('NavigationBloc', () {
      blocTest(
        "emits state to notify UI to naviagte to next page when NavigateToNextPage is called",
        build: () {
          return NavigationBloc();
        },
        act: (bloc) => bloc.add(NavigateToNextPage()),
        expect: () => [
          NavigatedToNextPage(),
        ],
      );
      blocTest(
        "emits state to notify UI to naviagte to page when OnFinishUserRegistration is called",
        build: () {
          return NavigationBloc();
        },
        act: (bloc) => bloc.add(OnFinishUserRegistration()),
        expect: () => [
          OnFinishedUserRegistration(),
        ],
      );
    });
  }
}
