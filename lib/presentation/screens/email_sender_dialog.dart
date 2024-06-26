import 'package:flutter/material.dart';
import 'email_sender.dart';
import 'package:task_management/core/data/models/task_model.dart';

class EmailSenderDialog extends StatefulWidget {
  final Task task;

  EmailSenderDialog({required this.task});

  @override
  _EmailSenderDialogState createState() => _EmailSenderDialogState();
}

class _EmailSenderDialogState extends State<EmailSenderDialog> {
  TextEditingController toEmailController = TextEditingController();

  @override
  void dispose() {
    toEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Task'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: toEmailController,
              decoration: InputDecoration(labelText: 'Recipient Email'),
            ),
            // Add other necessary text fields for email details
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Get user input from text controllers
            String fromEmail = 'umohmand52@gmail.com';
            String fromName = 'Admin';
            String toEmail = toEmailController.text;
            String subject = 'Task Assignment';
            String body =
                'Task details: ${widget.task.title}, ${widget.task.description}';

            // Validate the email address if needed
            if (isValidEmail(toEmail)) {
              // Send the email
              await EmailSender.sendEmail(
                fromEmail: fromEmail,
                fromName: fromName,
                toEmail: toEmail,
                subject: subject,
                body: body,
              );

              // Close the dialog
              Navigator.of(context).pop();
            } else {
              // Show an error message or handle invalid email address
              print('Invalid email address');
            }
          },
          child: Text('Send'),
        ),
      ],
    );
  }

  bool isValidEmail(String email) {
    // Implement email validation logic here
    // You can use a regular expression or another validation method
    return email.isNotEmpty;
  }
}
