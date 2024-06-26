import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  static Future<void> sendEmail({
    required String fromEmail,
    required String fromName,
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    final smtpServer = gmail(fromEmail, 'csyl zvyp lirs zyls');

    final message = Message()
      ..from = Address(fromEmail, fromName)
      ..recipients.add(toEmail)
      ..subject = subject
      ..html = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
