import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:task_management/core/constants/app_constants.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/firebase_options.dart';
import 'package:task_management/presentation/screens/login_screen.dart';
import 'package:task_management/presentation/screens/signUp_screen.dart';
import 'package:task_management/presentation/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<SharedPreferences> _sharedPreferences;

  @override
  void initState() {
    super.initState();
    _sharedPreferences = SharedPreferences.getInstance();
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    firebaseMessaging.getToken().then((value) {
      print("FirebaseMessaging: ${value}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sharedPreferences,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          bool isAuthenticated = snapshot.data?.getBool('isAuthenticated') ?? false;

          FirebaseMessaging messaging = FirebaseMessaging.instance;

          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            print("Handling a foreground message: ${message.notification?.title}");
          });

          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            print("Handling a message opened app event: ${message.notification?.title}");
          });

          return ChangeNotifierProvider<UserRole>(
            create: (_) => UserRole(UserRoleType.unknown),
            child: MaterialApp(
              title: AppConstants.appName,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: isAuthenticated ? TaskListScreen() : SignUpScreen(),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}