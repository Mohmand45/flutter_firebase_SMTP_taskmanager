import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/core/constants/app_constants.dart';
import 'package:task_management/core/utils/acl.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/core/data/models/task_model.dart';
import 'package:task_management/core/data/services/task_service.dart';
import 'package:task_management/presentation/screens/task_details_screen.dart';
import 'package:task_management/presentation/screens/login_screen.dart';

class TaskListScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
          if (context
              .read<UserRole>()
              .userRoleType == UserRoleType.admin)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'createUser') {
                  await _handleCreate(context, _createUser);
                } else if (value == 'createManager') {
                  await _handleCreate(context, _createManager);
                }
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'createUser',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Create User'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'createManager',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Create Manager'),
                  ),
                ),
              ],
            ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              // Logout logic
              await SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('isAuthenticated', false);
              });
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: TaskService.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      task.description,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ACL.canEditTask(UserRoleType.user))
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit logic
                            },
                          ),
                        if (ACL.canDeleteTask(UserRoleType.user))
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              // Handle delete logic
                              await TaskService.deleteTask(task.id);
                            },
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            TaskDetailsScreen(task: task)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: context
            .read<UserRole>()
            .userRoleType == UserRoleType.admin,
        child: FloatingActionButton(
          onPressed: () {
            _handleCreate(context, _createUser);
          },
          child: Icon(
            Icons.add,
            size: 28.0,
          ),
          backgroundColor: Colors.purple,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _handleCreate(BuildContext context,
      Function createFunction) async {
    try {
      await createFunction(context);
      _showSuccessDialog(context, 'created successfully');
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      Navigator.of(context).pop();
    }
  }

  Future<void> _createUser(BuildContext context) async {
    try {
      var result = await _showCreateUserDialog(context);
      if (result != null) {
        String? email = result['email'];
        String? password = result['password'];

        await _auth.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        );

        await _firestore.collection('users').add({
          'email': email,
        });

        // _showSuccessDialog(context, 'User created successfully');
      }
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  Future<void> _createManager(BuildContext context) async {
    try {
      bool useExistingUsers = await _showSelectUserOptionDialog(context);

      if (useExistingUsers) {
        List<String>? selectedUsers = await _showSelectExistingUsersDialog(
            context);
        if (selectedUsers != null && selectedUsers.isNotEmpty) {
          await _moveUsersToManagers(context, selectedUsers);

          _showSuccessDialog(
              context, 'Selected users assigned as managers successfully');
        }
      } else {
        var result = await _showCreateUserDialog(context);
        if (result != null) {
          String? email = result['email'];
          String? password = result['password'];

          await _auth.createUserWithEmailAndPassword(
            email: email!,
            password: password!,
          );

          await _firestore.collection('managers').add({
            'email': email,
          });

          // _showSuccessDialog(context, 'Manager created successfully');
        }
      }
    } catch (e) {
      print("Error creating manager: $e");
    }
  }

  Future<bool> _showSelectUserOptionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Manager'),
          content: Text('Do you want to use existing users as managers?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Use existing users
              },
              child: Text('Use Existing Users'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Create a new manager
              },
              child: Text('Create New Manager'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<List<String>?> _showSelectExistingUsersDialog(
      BuildContext context) async {
    List<String> selectedUsers = [];

    return await showDialog<List<String>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Existing Users'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  var users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var userData = users[index].data() as Map<String,
                          dynamic>;
                      var userEmail = userData['email'] as String;

                      return ListTile(
                        title: Text(userEmail),
                        leading: Checkbox(
                          value: selectedUsers.contains(userEmail),
                          onChanged: (value) {
                            setState(() {
                              if (value != null && value) {
                                selectedUsers.add(userEmail);
                              } else {
                                selectedUsers.remove(userEmail);
                              }
                            },);
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(selectedUsers);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _moveUsersToManagers(BuildContext context,
      List<String> selectedUsers) async {
    for (var userEmail in selectedUsers) {
      var userQuery = await _firestore.collection('users').where(
          'email', isEqualTo: userEmail).get();

      if (userQuery.docs.isNotEmpty) {
        var userUid = userQuery.docs.first.id;

        var userData = userQuery.docs.first.data() as Map<String, dynamic>;

        await _firestore.collection('managers').add({
          'email': userEmail,
        });

        await _firestore.collection('users').doc(userUid).delete();

        // _showSuccessDialog(context, '$userEmail promoted to Managers '
        //     'successfully');
      }
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>?> _showCreateUserDialog(
      BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return showDialog<Map<String, String>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create User or Manager'),
          content: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop({
                  'email': emailController.text.trim(),
                  'password': passwordController.text.trim(),
                });
              },
              child: Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}