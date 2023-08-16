// ignore_for_file: library_private_types_in_public_api, unused_local_variable, avoid_print, use_build_context_synchronously, deprecated_member_use, unused_import
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../main_wrapper.dart';
import '../../utils/constants.dart';
import '../category/category.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final int _index = 2;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool isUserLoggedIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccountWithEmailAndPassword() async {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show the progress indicator
      });
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        final UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);

        // Save the username as a user property in Firebase Auth
        User? user = userCredential.user;
        if (user != null) {
          await user.updateProfile(displayName: username);
          await user
              .reload(); // Reload the user object to ensure the property is updated
        }

        // Display a success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Account Created'),
              content:
                  const Text('Your account has been successfully created.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        // Clear all fields
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } catch (e) {
        // Handle sign-up error
        print('Sign-up error: $e');
      } finally {
        setState(() {
          _isLoading = false; // Hide the progress indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter User Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 700),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter Your Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 900),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter New Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 1100),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Your Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                const SizedBox(height: 30),
                FadeIn(
                  delay: const Duration(milliseconds: 1300),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 131, 54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 10),
                      ),
                      onPressed: _createAccountWithEmailAndPassword,
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: FadeIn(
                    delay: const Duration(milliseconds: 1500),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Back to Log In Page',
                          style: TextStyle(color: Colors.orange, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBarBubble(
        color: primaryColor,
        selectedIndex: _index,
        items: [
          BottomBarItem(iconData: Icons.home),
          BottomBarItem(iconData: Icons.category),
          BottomBarItem(iconData: Icons.person),
        ],
        onSelect: (index) {
          if (index == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MainWrapper(isUserLoggedIn: isUserLoggedIn)));
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryScreen(
                          isUserLoggedIn: isUserLoggedIn,
                        )));
          }
        },
      ),
    );
  }
}
