// lib/presentation/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/core/utils/acl.dart';
import 'package:task_management/core/utils/data/user_role.dart';
import 'package:task_management/presentation/screens/task_list_screen.dart';
import 'package:task_management/presentation/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add this line

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isAuthenticated', true);
      });

      UserRoleType userRoleType = determineUserRoleType(userCredential.user?.email, 'users');
      context.read<UserRole>().updateUserRole(userRoleType);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TaskListScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors
      _showErrorDialog(context, e.message ?? 'An error occurred during authentication.');
    } catch (e) {
      // Handle other exceptions
      print("Error: $e");
    }
  }


  void _showErrorDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Authentication Error'),
          content: Text(content),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Login')),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelStyle: TextStyle(color: Colors.black, backgroundColor: Colors.white),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(

                labelText: 'Password',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelStyle: TextStyle(color: Colors.black, backgroundColor:
                Colors.white),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signIn(context),
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                onPrimary: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
              child: Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
  UserRoleType determineUserRoleType(String? email, String? collection) {
    if (email != null && email.endsWith('@admin.com')) {
      return UserRoleType.admin;
    } else if (email != null && collection != null) {
      if (collection == 'managers') {
        return UserRoleType.manager;
      } else if (collection == 'users') {
        return UserRoleType.user;
      }
    }
    return UserRoleType.user; // Default to UserRoleType.user if conditions are not met
  }

}

//   Future<UserRoleType> determineUserRoleType(String? userId) async {
//     if (userId != null) {
//       DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
//       if (userSnapshot.exists) {
//         return UserRoleType.user;
//       }
//
//       DocumentSnapshot managerSnapshot = await _firestore.collection('managers').doc(userId).get();
//       if (managerSnapshot.exists) {
//         return UserRoleType.manager;
//       }
//     }
//
//     // Default to UserRoleType.admin for admin or UserRoleType.user if not in 'managers' or 'users'
//     return userId != null && userId.endsWith('@admin.com') ? UserRoleType.admin : UserRoleType.user;
//   }
//
// }
