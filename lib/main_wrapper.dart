import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar_matu.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/user_account.dart';
import 'package:fashion_ecommerce_app/screens/category/category.dart';
import 'package:fashion_ecommerce_app/screens/LogInSignUp/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'model/base_model.dart';
import 'screens/cart/cart.dart';
import 'screens/home/home.dart';
import 'screens/search/search.dart';
import '../utils/constants.dart';

class MainWrapper extends StatefulWidget {
  final bool isUserLoggedIn;

  const MainWrapper({Key? key, required this.isUserLoggedIn}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final int _index = 0;
  bool isSearchActive = false;
  int cartItemCount = 0; // Track the number of items in the cart

  List<Widget> screens = [
    const Home(),
    const Search(),
  ];

  @override
  void initState() {
    super.initState();
    // Call getCartItemCount when the widget initializes
    getCartItemCount();
  }

  void getCartItemCount() async {
    // Call the getCartItemCount method in the Cart class to retrieve the item count
    int itemCount = await Cart.getCartItemCount();
    setState(() {
      cartItemCount = itemCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isUserLoggedIn = widget.isUserLoggedIn;
    List<BaseModel> products = [];

    const int x = 1;
    return Scaffold(
      appBar: AppBar(
        title: isSearchActive
            ? FadeIn(
                delay: const Duration(milliseconds: 300),
                child: const Text(
                  "Search",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              )
            : FadeIn(
                delay: const Duration(milliseconds: 300),
                child: const Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchActive = !isSearchActive;
              });
            },
            icon: isSearchActive
                ? const Icon(
                    LineIcons.searchMinus,
                    color: Colors.black,
                    size: 30,
                  )
                : const Icon(
                    LineIcons.search,
                    color: Colors.black,
                    size: 30,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    LineIcons.shoppingBag,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Cart(isUserLoggedIn: isUserLoggedIn),
                      ),
                    );
                  },
                ),
                if (cartItemCount >= 0)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartItemCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: isSearchActive ? const Search() : const Home(),
      bottomNavigationBar: BottomBarBubble(
        color: primaryColor,
        selectedIndex: _index,
        items: [
          BottomBarItem(iconData: Icons.home),
          BottomBarItem(iconData: Icons.category),
          BottomBarItem(iconData: Icons.person),
        ],
        onSelect: (index) {
          if (index == 2) {
            if (isUserLoggedIn) {
              FirebaseAuth auth = FirebaseAuth.instance;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserAccount(
                            email: auth.currentUser!.email ?? '',
                            username: auth.currentUser!.displayName ?? '',
                           
                          )));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Login(
                            x: x,
                            fromWhere: 0,
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
                          )));
            }
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CategoryScreen(isUserLoggedIn: isUserLoggedIn)));
          }
        },
      ),
    );
  }
}
