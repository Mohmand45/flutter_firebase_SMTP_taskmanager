import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/data/models/task_model.dart';
import 'package:task_management/core/data/services/task_service.dart';
import 'package:task_management/presentation/screens/email_sender.dart';
import 'package:task_management/presentation/screens/manager_list_screen_assign.dart';
import 'package:task_management/presentation/screens/task_update_screen.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/presentation/screens/email_sender_dialog.dart';
import 'package:task_management/presentation/screens/user_list_screen_assign.dart';
class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  TaskDetailsScreen({required this.task});

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await TaskService.deleteTask(task.id);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Close the task details screen
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserRoleType userRoleType = context.read<UserRole>().userRoleType;

    print("UserRoleType: $userRoleType"); // Debugging statement

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskDetailItem(title: 'Title', subtitle: task.title),
                    TaskDetailItem(title: 'Description', subtitle: task.description),
                    TaskDetailItem(title: 'Status', subtitle: task.status),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Visibility(
                visible: userRoleType == UserRoleType.admin,
                child: Positioned(
                  bottom: 200,
                  right: 8.0,
                  left: 8.0,
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(borderRadius: 
                          BorderRadius.circular(10))
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserListScreen()),
                          );
                        },
                        child: Text('Assign User',
                        style: TextStyle(
                          color: Colors.white,
                        ),),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(10))
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ManagerListScreen(task: task)),
                          );
                        },
                        child: Text('Assign Manager',
                          style: TextStyle(
                            color: Colors.white,
                          ),),
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned icons at the bottom right
              if (userRoleType == UserRoleType.admin || userRoleType == UserRoleType.manager)
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  child: Container(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.green,
                          onPressed: () {
                            // Navigate to the task update screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskUpdateScreen(task: task),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            // Show delete confirmation dialog
                            _showDeleteConfirmationDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

    );
  }
}

class TaskDetailItem extends StatelessWidget {
  final String title;
  final String subtitle;

  TaskDetailItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.purple, // You can change the color
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        Divider(
          height: 20.0,
          color: Colors.grey.withOpacity(0.7),
        ),
      ],
    );
  }
}