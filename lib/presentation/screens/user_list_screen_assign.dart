import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<String> selectedUsers = [];
  List<String> assignedTasks = [];
  bool isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    // Load the list of tasks that have already been assigned to users
    loadAssignedTasks();
  }

  Future<void> loadAssignedTasks() async {
    // Replace 'assigned_tasks' with the actual collection name where you store assigned tasks
    var snapshot = await FirebaseFirestore.instance.collection('assigned_tasks').get();

    setState(() {
      assignedTasks = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        actions: [
          IconButton(
            onPressed: isSendingEmail ? null : () {
              sendAssignmentEmail(selectedUsers);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              var userEmail = userData['email'] as String;
              var isAssigned = assignedTasks.contains(userEmail);

              return ListTile(
                title: Text(userEmail),
                leading: Checkbox(
                  value: selectedUsers.contains(userEmail),
                  onChanged: (value) {
                    if (!isAssigned) {
                      setState(() {
                        if (value != null && value) {
                          selectedUsers.add(userEmail);
                        } else {
                          selectedUsers.remove(userEmail);
                        }
                      });
                    }
                  },
                ),
                tileColor: isAssigned ? Colors.grey : null,
                onTap: isAssigned ? null : () {},
              );
            },
          );
        },
      ),
    );
  }

  Future<void> sendAssignmentEmail(List<String> selectedUsers) async {
    setState(() {
      isSendingEmail = true;
    });

    final smtpServer = gmail('umohmand52@gmail.com', 'csyl zvyp lirs zyls');

    final message = Message()
      ..from = Address('umohmand52@gmail.com', 'Admin')
      ..recipients.addAll(selectedUsers)
      ..subject = 'Task Assignment'
      ..text = 'You have been assigned a new task. Details: ...';

    try {
      await send(message, smtpServer);
      print('Email sent successfully');
    } catch (error) {
      print('Error sending email: $error');
    } finally {
      setState(() {
        isSendingEmail = false;
      });

      // Show success dialog
      _showSuccessDialog(context, 'Emails sent successfully');
    }
  }

  // Function to show success dialog
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
}
