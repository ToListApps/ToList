import 'package:firebase_auth/firebase_auth.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();

  User? _user;

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  void setUser(User? user) {
    _user = user;
  }

  User? getUser() => _user;
}