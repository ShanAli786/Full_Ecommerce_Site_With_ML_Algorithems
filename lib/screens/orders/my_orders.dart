// ignore_for_file: prefer_const_declarations, no_leading_underscores_for_local_identifiers, avoid_function_literals_in_foreach_calls, avoid_print, await_only_futures, unused_local_variable

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar_matu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../../main_wrapper.dart';
import '../../model/order_model.dart';
import '../../utils/constants.dart';
import '../category/category.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List<RecentOrder> _recentOrders = [];

  Future<List<RecentOrder>> fetchData() async {
    final user = await FirebaseAuth.instance.currentUser;
    List<RecentOrder> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('orders')
          .doc(user?.email)
          .collection("data")
          .get();

      snapshot.docs.forEach((doc) {
        RecentOrder product = RecentOrder.fromMap(doc.data());
        products.add(product);
      });
      print("Data Fetched Successful");
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _recentOrders = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildNavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: const Text(
                    "Recent Orders",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Orders History!'),
                            content: const Text(
                                'Are you sure you want to delete all orders?'),
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
                                onPressed: () {
                                  clearOrders();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Clear History",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                // Add some space between texts
              ],
            ),
          ),
          FadeIn(
            delay: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey[300],
              child: Row(
                children: const [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Order#",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Items",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Size",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Color",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Quantity",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Price",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FadeIn(
              delay: const Duration(milliseconds: 800),
              child: _recentOrders.isEmpty
                  ? const Center(
                      child: Text(
                        "No orders yet!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentOrders.length,
                      itemBuilder: (context, index) {
                        final sizeString =
                            getSizeString(_recentOrders[index].size);
                        final colorString =
                            getColorString(_recentOrders[index].color);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color:
                              index % 2 == 0 ? Colors.grey[200] : Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                    _recentOrders[index].orderNo.toString()),
                              ),
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.network(
                                          _recentOrders[index].itemPic,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(sizeString),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(colorString),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                    _recentOrders[index].quantity.toString()),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                    "\$${_recentOrders[index].totalPrice}"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: FadeIn(
        delay: const Duration(milliseconds: 200),
        child: const Text(
          "My Orders",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  BottomBarBubble _buildNavBar() {
    final int _index = 2;
    return BottomBarBubble(
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
              builder: (context) => const MainWrapper(isUserLoggedIn: true),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryScreen(
                isUserLoggedIn: true,
              ),
            ),
          );
        }
      },
    );
  }

  String getSizeString(int size) {
    switch (size) {
      case 0:
        return "S";
      case 1:
        return "M";
      case 2:
        return "L";
      case 3:
        return "XL";
      case 4:
        return "XXL";
      default:
        return "N/A";
    }
  }

  // Function to get the human-readable color based on the integer value
  String getColorString(int color) {
    switch (color) {
      case 0:
        return "White";
      case 1:
        return "Black";
      case 2:
        return "Blue";
      case 3:
        return "Green";
      case 4:
        return "Grey";
      case 5:
        return "Blue Grey";
      case 6:
        return "Yellow";
      default:
        return "N/A";
    }
  }

  Future<void> clearOrders() async {
    final user = await FirebaseAuth.instance.currentUser;
    try {
      final CollectionReference<Map<String, dynamic>> usersCartCollection =
          FirebaseFirestore.instance.collection('orders');
      await usersCartCollection
          .doc(user?.email)
          .collection('data')
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      print('Order deleted successfully.');

      // Fetch updated orders after clearing
      fetchData().then((data) {
        setState(() {
          _recentOrders = data;
        });
      });
    } catch (e) {
      print('Error deleting order: $e');
    }
  }
}
