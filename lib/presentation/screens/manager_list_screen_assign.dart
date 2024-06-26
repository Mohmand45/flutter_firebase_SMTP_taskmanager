import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:task_management/core/data/models/task_model.dart';

class ManagerListScreen extends StatefulWidget {
  final Task task;

  ManagerListScreen({
    required this.task,
  });

  @override
  _ManagerListScreenState createState() => _ManagerListScreenState();
}

class _ManagerListScreenState extends State<ManagerListScreen> {
  List<String> selectedManagers = [];
  List<String> assignedTasks = [];
  bool isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    // Load the list of tasks that have already been assigned to managers
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
        title: Text('Managers List'),
        actions: [
          IconButton(
            onPressed: isSendingEmail ? null : () async {
              // Assign the task to selected managers
              for (final managerEmail in selectedManagers) {
                await assignTaskToManager(widget.task.id, managerEmail); // Use task.id
              }

              // Send email to selected managers
              await sendAssignmentEmail(selectedManagers, widget.task.title, widget.task.description); // Use task.title and task.description
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('managers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var managers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: managers.length,
            itemBuilder: (context, index) {
              var managerData = managers[index].data() as Map<String, dynamic>;
              var managerEmail = managerData['email'] as String;
              var isAssigned = assignedTasks.contains(widget.task.id);

              return ListTile(
                title: Text(managerEmail),
                leading: Checkbox(
                  value: selectedManagers.contains(managerEmail),
                  onChanged: (value) {
                    if (!isAssigned) {
                      setState(() {
                        if (value != null && value) {
                          selectedManagers.add(managerEmail);
                        } else {
                          selectedManagers.remove(managerEmail);
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

  Future<void> assignTaskToManager(String taskId, String managerEmail) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('managers')
        .where('email', isEqualTo: managerEmail)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userUid = userQuery.docs.first.id;

      await FirebaseFirestore.instance.collection('managers').doc(userUid).set({
        'assigned_tasks': FieldValue.arrayUnion([taskId]),
      }, SetOptions(merge: true));
    }
  }

  Future<void> sendAssignmentEmail(List<String> selectedManagers, String taskTitle, String taskDescription) async {
    setState(() {
      isSendingEmail = true;
    });

    final smtpServer = gmail('umohmand52@gmail.com', 'csyl zvyp lirs zyls');

    final message = Message()
      ..from = Address('umohmand52@gmail.com', 'Admin')
      ..recipients.addAll(selectedManagers)
      ..subject = 'Task Assignment'
      ..text = 'You have been assigned a new task.\n\nTitle: $taskTitle\nDescription: $taskDescription';

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
