import 'package:task_management/core/errors/custom_errors.dart';
import 'package:task_management/core/utils/data/user_role.dart';

class ACL {
  static bool canEditTask(UserRoleType userRoleType) {
    return userRoleType == UserRoleType.admin || userRoleType == UserRoleType.manager;
  }

  static bool canViewTask(UserRoleType userRoleType) {
    return userRoleType == UserRoleType.admin || userRoleType == UserRoleType.user || userRoleType == UserRoleType.manager;
  }

  static bool canDeleteTask(UserRoleType userRoleType) {
    return userRoleType == UserRoleType.admin || userRoleType == UserRoleType.manager;
  }

  static bool canCreateTask(UserRoleType userRoleType) {
    return userRoleType == UserRoleType.admin;
  }

  static bool canMarkTaskAsDone(UserRoleType userRole) {
    // Logic to determine if the user can mark tasks as done based on user role
    return userRole == UserRoleType.user;
  }

  static bool canApproveTask(UserRoleType userRole) {
    // Logic to determine if the user can approve tasks based on user role
    return userRole == UserRoleType.admin;
  }

  static void createTask(UserRoleType userRoleType) {
    if (!canCreateTask(userRoleType)) {
      throw CustomError('Access denied. Only admins can create tasks.');
    }

    // Implement task creation logic here
    print('Task created successfully!');
  }
}
