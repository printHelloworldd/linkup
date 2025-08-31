import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/firestore/get_all_users_usecase.dart';
import 'package:linkup/features/Search%20User/presentation/bloc/filter_users_bloc.dart';

class MockGetAllUsersUc extends Mock implements GetAllUsersUsecase {}

class FilterUserBlocTest {
  FilterUserBlocTest() {
    _testFilterUsersBloc();
  }

  static void _testFilterUsersBloc() {
    late MockGetAllUsersUc mockUc;

    setUp(() {
      mockUc = MockGetAllUsersUc();
    });

    group('FilterUsersBloc', () {
      blocTest(
        "emits all users and filtered users when GetAllUsers and SearchUsersEvent are called",
        build: () {
          when(() => mockUc.call()).thenAnswer((_) async => const Right([
                UserEntity(
                  id: '1',
                  email: '',
                  fullName: 'Rico',
                  hobbies: [],
                  blockedUsers: [],
                )
              ]));
          return FilterUsersBloc(getAllUsersUsecase: mockUc);
        },
        act: (bloc) => bloc
          ..add(GetAllUsers())
          ..add(const SearchUsersEvent(query: "Rico")),
        expect: () => [
          GettingAllUsers(),
          const GotAllUsers(allUsers: [
            UserEntity(
              id: '1',
              email: '',
              fullName: 'Rico',
              hobbies: [],
              blockedUsers: [],
            )
          ]),
          const SearchedUsers(filteredUsers: [
            UserEntity(
              id: '1',
              email: '',
              fullName: 'Rico',
              hobbies: [],
              blockedUsers: [],
            )
          ])
        ],
      );
    });
  }
}
