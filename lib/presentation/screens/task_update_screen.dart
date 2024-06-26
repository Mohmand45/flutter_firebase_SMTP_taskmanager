import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/utils/acl.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/core/data/models/task_model.dart';
import 'package:task_management/core/data/services/task_service.dart';

class TaskUpdateScreen extends StatelessWidget {
  final Task task;

  TaskUpdateScreen({required this.task});

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _statusController.text = task.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Task',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange, // Orange appbar background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _statusController,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final updatedTask = Task(
                          id: task.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          status: _statusController.text,
                        );

                        if (ACL.canEditTask(context.read<UserRole>().userRoleType)) {
                          await TaskService.updateTask(updatedTask);

                          // Show a success dialog
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Task Updated Successfully'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pop(context); // Close the update task screen
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.purple, // Purple button color
                                    ),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Handle permission denied
                          print('Permission denied to update task');
                        }
                      },
                      child: Text('Update Task'),
                      style: ElevatedButton.styleFrom(
                        primary: ACL.canEditTask(context.read<UserRole>().userRoleType)
                            ? Colors.purple // Purple button color
                            : Colors.white,
                        textStyle: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text color
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}