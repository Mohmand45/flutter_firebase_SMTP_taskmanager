import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/core/utils/acl.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/core/data/models/task_model.dart';
import 'package:task_management/core/data/services/task_service.dart';
import 'package:task_management/presentation/screens/task_details_screen.dart';

class TaskCreateScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Task Information',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(fontSize: 18.0),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _statusController,
                  style: TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (ACL.canCreateTask(context.read<UserRole>().userRoleType)) {
                        final newTask = Task(
                          id: UniqueKey().toString(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          status: _statusController.text,
                        );

                        await TaskService.createTask(newTask);

                        // Show a success dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Task Created Successfully'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );

                        // Navigate to the task details screen with the newly created task
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(task: newTask),
                          ),
                        );
                      } else {
                        // Handle permission denied
                        print('Permission denied to create task');
                      }
                    },
                    child: Text('Create Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
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