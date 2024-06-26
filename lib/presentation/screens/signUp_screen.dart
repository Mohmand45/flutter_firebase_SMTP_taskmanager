import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/presentation/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _passwordError = '';
  String _emailError = '';
  String _warningMessage = '';

  Future<void> _signUp() async {
    // Check if any field is left blank
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _warningMessage = 'Please fill in all the fields.';
      });
      return;
    } else {
      setState(() {
        _warningMessage = '';
      });
    }

    try {
      // Check if the email domain is allowed
      if (!_isAllowedDomain(_emailController.text.trim())) {
        _showDomainErrorDialog();
        return;
      }

      // Check if password and confirm password match
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _passwordError = 'Password and Confirm Password must match.';
        });
        return;
      } else {
        setState(() {
          _passwordError = '';
        });
      }

      // Check if the email already exists
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Set user authentication status in shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('isAuthenticated', true);
        });

        // Additional user data (e.g., full name) can be saved to Firebase Firestore or other databases.

        print('User signed up: ${_auth.currentUser?.email}');

        // Show success dialog and navigate to login screen
        _showSuccessDialog();
        await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            _emailError = 'Email already exists. Please use a different email.';
          });
        }
      }
    } catch (e) {
      // Handle signup errors
      print("Error: $e");
    }
  }

  bool _isAllowedDomain(String email) {
    // Define the allowed domains
    final allowedDomains = ["admin.com", "manager.com", "user.com"];

    // Extract the domain from the email
    final domain = email.split('@').last;

    // Check if the domain is allowed
    return allowedDomains.contains(domain);
  }

  void _showDomainErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Email Domain'),
          content: Text('The email domain must be @admin.com, @manager.com, or @user.com.'),
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

  void _showSuccessDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created successfully!'),
        duration: Duration(seconds: 2), // Show for 2 seconds
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black, backgroundColor: Colors.white),
                  errorText: _emailError,
                ),
                keyboardType: TextInputType.emailAddress,
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
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(color: Colors.black, backgroundColor: Colors.white),
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _signUp();
                },
                child: Text('Sign Up',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                ),
              ),
              Text(
                _warningMessage,
                style: TextStyle(color: Colors.black),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                child: Text('Already have an account? Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}