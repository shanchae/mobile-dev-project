// screens/login_screen.dart

// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isPasswordVisible = false;

  Future<void> _signInWithEmailAndPassword() async {
    User? user = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );    
    } else {
      // Show an error message
    }
  }

  Future<void> _signInWithGoogle() async {
    // Implement sign-in with Google
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.red[100],
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recipe App',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
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
                      borderRadius: BorderRadius.all(Radius.circular(30.0)))),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Icon(Icons.password),
                ),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                suffixIcon: IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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
              onPressed: _signInWithEmailAndPassword,
              child: Text('Log In'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text('Sign In with Google'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
