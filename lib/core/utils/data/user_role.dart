import 'package:flutter/material.dart';

enum UserRoleType { admin, manager, user, unknown }

class UserRole with ChangeNotifier {
  UserRoleType _userRoleType;

  UserRole(this._userRoleType);

  UserRoleType get userRoleType => _userRoleType;

  void updateUserRole(UserRoleType newUserRoleType) {
    _userRoleType = newUserRoleType;
    notifyListeners();
  }
}

