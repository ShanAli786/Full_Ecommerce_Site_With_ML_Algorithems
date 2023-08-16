// ignore_for_file: deprecated_member_use, avoid_print

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:fashion_ecommerce_app/admin/dashboard/dashboard.dart';
import 'package:fashion_ecommerce_app/admin/customers/manage_customers.dart';
import 'package:fashion_ecommerce_app/admin/orders/manage_orders.dart';
import 'package:fashion_ecommerce_app/admin/products/manage_products.dart';
import 'package:fashion_ecommerce_app/model/base_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/LogInSignUp/login.dart';
import '../../utils/constants.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final int _index = 0;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: FadeIn(
          delay: const Duration(milliseconds: 300),
          child: const Text(
            "Home",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    TextButton(
                      onPressed: _logOut,
                      child: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Smart",
                            style: textTheme.headline1,
                            children: [
                              TextSpan(
                                text: " Shopping",
                                style: textTheme.headline1?.copyWith(
                                  color: Colors.orange,
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            text: "Manage the app ",
                            style: TextStyle(
                              color: Color.fromARGB(186, 0, 0, 0),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: "freely :)",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            top: size.height * 0.18, // Adjust the value as needed
            child: FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16.0),
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  buildMenuButton(context, 'Dashboard', () {}),
                  buildMenuButton(context, 'Products', () {
                    // Add navigation logic for Products here
                  }),
                  buildMenuButton(context, 'Orders', () {
                    // Add navigation logic for Orders here
                  }),
                  buildMenuButton(context, 'Feedbacks', () {
                    // Add navigation logic for Customers here
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBarBubble(
        color: primaryColor,
        selectedIndex: _index,
        items: [
          BottomBarItem(iconData: Icons.home),
          // BottomBarItem(iconData: Icons.dashboard),
          // BottomBarItem(iconData: Icons.person),
          // BottomBarItem(iconData: Icons.production_quantity_limits),
        ],
        onSelect: (index) {
          // if (index == 1) {
          //   Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const Dashboard()));
          // } else if (index == 2) {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const ManageCustomers()));
          // } else if (index == 3) {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const ManageProducts()));
          // }
        },
      ),
      floatingActionButton: FadeIn(
        delay: const Duration(milliseconds: 2000),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 131, 54),
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
          ),
          onPressed: _logOut,
          child: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _logOut() {
    const int x = 1;
    final List<BaseModel> products = [];
    FirebaseAuth.instance.signOut().then((_) {
      // Log out successful, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Login(
                  fromWhere: 0,
                  x: x,
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
                )),
      );
    }).catchError((error) {
      // Handle logout error if necessary
      print('Logout error: $error');
    });
  }

  Widget buildMenuButton(
      BuildContext context, String title, void Function()? onPressed) {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: onPressed != null
              ? () {
                  if (title == 'Dashboard') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Dashboard()),
                    );
                  } else if (title == 'Products') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageProducts()),
                    );
                  } else if (title == 'Orders') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageOrders()));
                  } else if (title == 'Customers') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageCustomers()));
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 175, 54),
            padding: const EdgeInsets.all(16.0),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              inherit: false, // Set the inherit property to false
            ),
          ),
        ),
      ),
    );
  }
}
