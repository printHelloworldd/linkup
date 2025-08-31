// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'filter_users_bloc.dart';

sealed class FilterUsersState extends Equatable {
  const FilterUsersState();

  @override
  List<Object> get props => [];
}

final class FilterUsersInitial extends FilterUsersState {}

class GettingAllUsers extends FilterUsersState {}

class GotAllUsers extends FilterUsersState {
  final List<UserEntity> allUsers;

  const GotAllUsers({
    required this.allUsers,
  });

  @override
  List<Object> get props => [allUsers];
}

class GettingAllUsersFailure extends FilterUsersState {
  final Object exception;

  const GettingAllUsersFailure({
    required this.exception,
  });

  @override
  List<Object> get props => [exception];
}

class SearchedUsers extends FilterUsersState {
  final List<UserEntity> filteredUsers;

  const SearchedUsers({
    required this.filteredUsers,
  });

  @override
  List<Object> get props => [filteredUsers];
}
