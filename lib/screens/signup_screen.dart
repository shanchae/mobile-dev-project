// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isPasswordVisible = false;

  Future<void> _signUpWithEmailAndPassword() async {
    // Implement sign-up with email/password
    User? user = await _authService.signUpWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (user != null) {
      // Navigate to the login screen
      Navigator.pop(context);
    } else {
      // Show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  fontFamily: 'Nunito',
                  color: Color.fromARGB(255, 184, 7, 66)),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Icon(Icons.email),
                  ),
                  labelText: 'Email',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0))
                    )
                  ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Icon(Icons.password),
                ),
                border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    })
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signUpWithEmailAndPassword,
              child: Text('Sign Up'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithGoogle();

                if (user != null) {
                  Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  // Sign-up failed
                  // Handle accordingly, e.g., show an error message
                }
              },
              child: Text('Sign Up with Google'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Already have an account? Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
