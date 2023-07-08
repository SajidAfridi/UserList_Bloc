part of 'user_list_bloc.dart';

@immutable
abstract class UserListState {
  List<User> users;
  UserListState({required this.users});
}

class UserListInitial extends UserListState {
  UserListInitial({required super.users});
}

class UserListUpdated extends UserListState {
  UserListUpdated({required super.users});
}
