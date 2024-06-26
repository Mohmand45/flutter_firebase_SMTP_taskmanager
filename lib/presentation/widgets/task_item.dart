// lib/presentation/widgets/task_item.dart
import 'package:flutter/material.dart';
import 'package:task_management/core/utils/acl.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/core/data/models/task_model.dart';
import 'package:task_management/presentation/screens/task_details_screen.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final bool canEdit;
  final bool canDelete;

  TaskItem({required this.task, required this.canEdit, required this.canDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(task: task),
          ),
        );
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEdit)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Implement edit functionality
              },
            ),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Implement delete functionality
              },
            ),
        ],
      ),
    );
  }
}