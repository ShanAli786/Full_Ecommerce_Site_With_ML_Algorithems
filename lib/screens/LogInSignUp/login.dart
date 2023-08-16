// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/admin/home/admin_home.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/signup.dart';
import 'package:fashion_ecommerce_app/screens/ProductDetail/details.dart';
import 'package:fashion_ecommerce_app/screens/cart/cart.dart';
import 'package:fashion_ecommerce_app/screens/category/category.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/user_account.dart';
import 'package:fashion_ecommerce_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../model/base_model.dart';

class Login extends StatefulWidget {
  final int x;
  final BaseModel data;
  final int fromWhere;
 
  const Login(
      {Key? key, required this.x, required this.data, required this.fromWhere})
      : super(key: key);
  int? get getFromWhere => fromWhere;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _index = 2;
  int xValue = 0;
  List<BaseModel> products = [];
  int fromWhere = 0;

  bool isCustomerChecked = false;
  bool isAlumniChecked = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailFieldFocused = false;
  bool _isPasswordFieldFocused = false;
  bool _isLoading = false;
  bool isUserLoggedIn = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  Future<void> signInWithGoogle() async {
    try {
      

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        
        final User? user = userCredential.user;
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserAccount(
                email: user.email!,
                username: user.displayName!,

              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFieldFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFieldFocused = _passwordFocusNode.hasFocus;
      });
    });
    xValue = widget.x;
    fetchData().then((data) {
      setState(() {
        products = data;
      });
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    fromWhere = widget.fromWhere;
    setState(() {
      _isLoading = true; // Show the progress bar
    });

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Handle successful login and navigate to the necessary page
      if (userCredential.user != null) {
        if (isCustomerChecked) {
          // Verify if the user is not an admin
          if (_emailController.text.trim() != 'admin.smart@gmail.com' ||
              _passwordController.text.trim() != 'admin1234') {
            if (xValue == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAccount(
                    email: _emailController.text.trim(),
                    username: userCredential.user!.displayName ?? '',
                  ),
                ),
              );
            } else if (xValue == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Details(
                            data: products.isNotEmpty
                                ? products[0]
                                : BaseModel(
                                    id: 1,
                                    imageUrl: "imageUrl",
                                    name: "name",
                                    category: "category",
                                    price: 1.0,
                                    review: 1.2,
                                    value: 1,
                                    selectedSize: 1,
                                    selectedColor: 1),
                            isCameFromMostPopularPart: false,
                            isUserLoggedIn: true,
                            isCameFromLogIn: true,
                            fromWhere: fromWhere,
                          )));
            } else if (xValue == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Cart(isUserLoggedIn: true)));
            }
          } else {
            // Show error dialog for admin attempting to access customer screen
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Access Denied'),
                  content: const Text(
                      'You are not authorized to access the customer screen.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else if (isAlumniChecked) {
          // Verify admin credentials
          if (_emailController.text.trim() == 'admin.smart@gmail.com' &&
              _passwordController.text.trim() == 'admin1234') {
            // Navigate to the admin home screen for admins
            // Replace 'AdminHomeScreen' with the appropriate admin screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHome(),
              ),
            );
          } else {
            // Show error dialog for incorrect admin credentials
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Admin Login Error'),
                  content:
                      const Text('Invalid email or password for admin login.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      // Handle login errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the progress bar
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, isUserLoggedIn, xValue),
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
                    builder: (context) => MainWrapper(
                          isUserLoggedIn: isUserLoggedIn,
                        )));
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeIn(
                delay: const Duration(milliseconds: 300),
                child: const CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/images/login.png'), // Replace with your avatar image path
                  radius: 80, // Adjust the avatar size as desired
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.orange,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: _isEmailFieldFocused
                            ? Colors.orange
                            : const Color.fromARGB(255, 63, 61, 61),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 700),
                child: SizedBox(
                  height: 50,
                  width: 300,
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.orange,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.key,
                        color: _isPasswordFieldFocused
                            ? Colors.orange
                            : const Color.fromARGB(255, 63, 61, 61),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 900),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isCustomerChecked,
                      onChanged: (value) {
                        setState(() {
                          isCustomerChecked = value ?? false;
                          if (isCustomerChecked) {
                            isAlumniChecked = false;
                          }
                        });
                      },
                    ),
                    const Text('Customer'),
                    const SizedBox(width: 10),
                    Checkbox(
                      value: isAlumniChecked,
                      onChanged: (value) {
                        setState(() {
                          isAlumniChecked = value ?? false;
                          if (isAlumniChecked) {
                            isCustomerChecked = false;
                          }
                        });
                      },
                    ),
                    const Text('Admin'),
                  ],
                ),
              ),
              if (_isLoading) // Show the progress bar if loading is in progress
                const CircularProgressIndicator(
                  color: Colors.orange,
                ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 1100),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 131, 54),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 10),
                  ),
                  onPressed: _signInWithEmailAndPassword,
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 1300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp(
                                      key: null,
                                    )));
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              FadeIn(
                delay: const Duration(milliseconds: 1700),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 130, vertical: 0),
                  child: FractionallySizedBox(
                    widthFactor:
                        1.5, // Adjust the width of the button (0.8 represents 80% of the available width)
                    child: ElevatedButton.icon(
                      onPressed: () {
                        signInWithGoogle();
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(
                              255, 255, 131, 54), // Customize the button color
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30), // Adjust the border radius
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<BaseModel>> fetchData() async {
    List<BaseModel> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      snapshot.docs.forEach((doc) {
        BaseModel product = BaseModel.fromMap(doc.data());
        products.add(product);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn, int xValue) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Log In",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          if (xValue == 0 || xValue == 2) {
            Navigator.pop(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CategoryScreen(isUserLoggedIn: isUserLoggedIn)));
          }
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
