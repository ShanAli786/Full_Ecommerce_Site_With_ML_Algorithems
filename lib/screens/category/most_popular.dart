// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fashion_ecommerce_app/main_wrapper.dart';

import 'package:fashion_ecommerce_app/screens/LogInSignUp/login.dart';
import 'package:fashion_ecommerce_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../model/base_model.dart';
import '../../widget/add_to_cart.dart';
import '../LogInSignUp/user_account.dart';
import '../ProductDetail/details.dart';

class MostPopular extends StatefulWidget {
  final bool isUserLoggedIn;
  const MostPopular({Key? key, required this.isUserLoggedIn}) : super(key: key);
  bool get getIsUserLoggedIn => isUserLoggedIn;

  @override
  State<MostPopular> createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular>
    with SingleTickerProviderStateMixin {
  List<BaseModel> products = [];
  bool isSearchActive = false;
  final int _index = 1;
  Set<Object> usedTags = {};

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        products = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    bool isUserLoggedIn = widget.getIsUserLoggedIn;
    int selectedSize = 1;
    int selectedColor = 1;
    const int x0 = 0;
    const int x1 = 1;
    const bool isCameFromLogIn = false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, isUserLoggedIn),
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
                      MainWrapper(isUserLoggedIn: isUserLoggedIn),
                ));
          } else if (index == 2 && isUserLoggedIn) {
            FirebaseAuth auth = FirebaseAuth.instance;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserAccount(
                        email: auth.currentUser!.email ?? '',
                        username: auth.currentUser!.displayName ?? '')));
          } else if (index == 2 && !isUserLoggedIn) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Login(
                          x: x1,
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
        },
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.63,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                BaseModel current = products[index];
                Object tag = ObjectKey(current.id);
                // Ensure the tag is unique
                if (usedTags.contains(tag)) {
                  // Generate a new unique tag if there is a conflict
                  tag = ObjectKey('${current.id}_$index');
                } else {
                  // Add the tag to the usedTags set
                  usedTags.add(tag);
                }
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          data: current,
                          isCameFromMostPopularPart: true,
                          isUserLoggedIn: isUserLoggedIn,
                          isCameFromLogIn: isCameFromLogIn,
                          fromWhere: 3,
                        ),
                      ),
                    ),
                    child: Hero(
                      tag: tag,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: size.height * 0.02,
                            left: size.width * 0.01,
                            right: size.width * 0.01,
                            child: Container(
                              width: size.width * 0.5,
                              height: size.height * 0.28,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                image: DecorationImage(
                                  image: NetworkImage(current.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 4,
                                    color: Color.fromARGB(61, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: size.height * 0.04,
                            child: Text(
                              current.name,
                              style: textTheme.headline2,
                            ),
                          ),
                          Positioned(
                            bottom: size.height * 0.01,
                            child: RichText(
                              text: TextSpan(
                                text: "\$",
                                style: textTheme.subtitle2?.copyWith(
                                  color: primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: current.price.toString(),
                                    style: textTheme.subtitle2?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: size.height * 0.01,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: IconButton(
                                onPressed: () {
                                  if (isUserLoggedIn) {
                                    AddToCart.addToCart(
                                      current,
                                      context,
                                      selectedSize,
                                      selectedColor,
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Login Required'),
                                          content: const Text(
                                              'Please log in to add items to your cart.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Login(
                                                              fromWhere: 0,
                                                              x: x0,
                                                              data: products.isNotEmpty
                                                                  ? products[0]
                                                                  : BaseModel(
                                                                      id: 1,
                                                                      imageUrl:
                                                                          "imageUrl",
                                                                      name:
                                                                          "name",
                                                                      category:
                                                                          "category",
                                                                      price:
                                                                          1.0,
                                                                      review:
                                                                          1.2,
                                                                     
                                                                      value: 1,
                                                                      selectedSize:
                                                                          1,
                                                                      selectedColor:
                                                                          1),
                                                            ))); // Close the dialog
                                              },
                                              child: const Text(
                                                'Log In',
                                                style: TextStyle(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                icon: const Icon(
                                  LineIcons.addToShoppingCart,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: products.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<BaseModel>> fetchData() async {
    List<BaseModel> products = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('PopularProducts').get();

      snapshot.docs.forEach((doc) {
        BaseModel product = BaseModel.fromMap(doc.data());

        // Filter the products to only include the most popular ones

        products.add(product);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }

    return products;
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Most Popular",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainWrapper(isUserLoggedIn: isUserLoggedIn)));
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
