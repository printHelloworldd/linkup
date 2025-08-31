// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'filter_users_bloc.dart';

sealed class FilterUsersEvent extends Equatable {
  const FilterUsersEvent();

  @override
  List<Object> get props => [];
}

class GetAllUsers extends FilterUsersEvent {}

class SearchUsersEvent extends FilterUsersEvent {
  final String query;

  const SearchUsersEvent({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}
