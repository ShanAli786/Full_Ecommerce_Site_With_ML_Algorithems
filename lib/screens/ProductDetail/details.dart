// ignore_for_file: deprecated_member_use, avoid_print, avoid_function_literals_in_foreach_calls, unused_local_variable

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/main_wrapper.dart';
import 'package:fashion_ecommerce_app/screens/Comments/comment_section.dart';
import 'package:fashion_ecommerce_app/screens/category/category.dart';
import 'package:fashion_ecommerce_app/screens/category/most_popular.dart';
import 'package:fashion_ecommerce_app/screens/search/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/base_model.dart';
import '../../utils/constants.dart';
import '../../widget/add_to_cart.dart';
import '../../widget/reuseable_text.dart';
import '../../widget/reuseable_button.dart';
import '../LogInSignUp/login.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;


class Details extends StatefulWidget {
  final bool isUserLoggedIn;
  final bool isCameFromLogIn;
  final int fromWhere;
  const Details({
    Key? key,
    required this.data,
    required this.isCameFromMostPopularPart,
    required this.isUserLoggedIn,
    required this.isCameFromLogIn,
    required this.fromWhere,
  }) : super(key: key);

  bool get getIsUserLoggedIn => isUserLoggedIn;
  bool get getIsCameFromLogIn => isCameFromLogIn;
  int? get getFromWhere => fromWhere;
  final BaseModel data;
  final bool isCameFromMostPopularPart;

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  List<BaseModel> products = [];
  int selectedSize = 0;
  int selectedColor = 0;
  int fromWhere = 0;

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        products = data;
      });
    });
    fromWhere = widget.getFromWhere!;
    saveProductToFirebase(widget.data);
    getImageUrlsFromFlask(widget.data.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    bool isUserLoggedIn = widget.getIsUserLoggedIn;
    BaseModel current = widget.data;
    const int x = 0;
    int reviews = 0;

    int? fromWhere = widget.fromWhere;

    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, isUserLoggedIn),
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Top Image
                SizedBox(
                  width: size.width,
                  height: size.height * 0.5,
                  child: Stack(
                    children: [
                      Hero(
                        tag: widget.isCameFromMostPopularPart
                            ? current.imageUrl
                            : current.id,
                        child: Container(
                          width: size.width,
                          height: size.height * 0.5,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(current.imageUrl),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: size.width,
                          height: size.height * 0.12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: gradient),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// info
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                current.name,
                                style:
                                    textTheme.headline3?.copyWith(fontSize: 22),
                              ),
                              ReuseableText(
                                price: current.price,
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.006,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommentSection(
                                              productName: current.name,
                                            ))),
                                child: FutureBuilder<int>(
                                  future: fetchReviews(current.name),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Loading reviews...",
                                        style: textTheme.headline5
                                            ?.copyWith(color: Colors.grey),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Error fetching reviews",
                                        style: textTheme.headline5
                                            ?.copyWith(color: Colors.red),
                                      );
                                    } else {
                                      final int reviews = snapshot.data ?? 0;
                                      return Text(
                                        "($reviews reviews)",
                                        style: textTheme.headline5
                                            ?.copyWith(color: Colors.grey),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CommentSection(
                                                productName: current.name,
                                              )));
                                },
                                child: const Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  color: Colors.grey,
                                  size: 15,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                /// Select size
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 18.0, bottom: 10.0),
                    child: Text(
                      "Select Size",
                      style: textTheme.headline3,
                    ),
                  ),
                ),

                ///Sizes
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    // color: Colors.red,
                    width: size.width * 0.9,
                    height: size.height * 0.08,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: sizes.length,
                        itemBuilder: (ctx, index) {
                          var current = sizes[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSize = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: AnimatedContainer(
                                width: size.width * 0.12,
                                decoration: BoxDecoration(
                                  color: selectedSize == index
                                      ? primaryColor
                                      : Colors.transparent,
                                  border:
                                      Border.all(color: primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                duration: const Duration(milliseconds: 200),
                                child: Center(
                                  child: Text(
                                    current,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: selectedSize == index
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),

                /// Select Color
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 18.0, bottom: 10.0),
                    child: Text(
                      "Select Color",
                      style: textTheme.headline3,
                    ),
                  ),
                ),

                ///Colors
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: size.width,
                    height: size.height * 0.08,
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: colors.length,
                        itemBuilder: (ctx, index) {
                          var current = colors[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: AnimatedContainer(
                                width: size.width * 0.12,
                                decoration: BoxDecoration(
                                  color: current,
                                  border: Border.all(
                                      color: selectedColor == index
                                          ? primaryColor
                                          : Colors.transparent,
                                      width: selectedColor == index ? 2 : 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                duration: const Duration(milliseconds: 200),
                              ),
                            ),
                          );
                        }),
                  ),
                ),

                /// Add To Cart Button
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height * 0.03),
                    child: ReuseableButton(
                      text: "Add to cart",
                      onTap: () {
                        if (isUserLoggedIn) {
                          AddToCart.addToCart(
                              current, context, selectedSize, selectedColor);
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
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login(
                                                    x: x,
                                                    data: current,
                                                    fromWhere: fromWhere,
                                                  ))); // Close the dialog
                                    },
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.favorite_border,
            color: Colors.white,
          ),
        ),
      ],
      leading: IconButton(
        onPressed: () {
          if (widget.getIsCameFromLogIn) {
            if (fromWhere == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MainWrapper(isUserLoggedIn: true)));
            } else if (fromWhere == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Search()));
            } else if (fromWhere == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const CategoryScreen(isUserLoggedIn: true)));
            } else if (fromWhere == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MostPopular(isUserLoggedIn: true)));
            }
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
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

  void saveProductToFirebase(BaseModel product) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String userEmail = user.email ?? '';

      try {
        String collectionName =
            "ContentBasedFiltering"; // Name of the Firestore collection

        // Create a reference to the products collection
        CollectionReference<Map<String, dynamic>> productsCollectionRef =
            FirebaseFirestore.instance.collection(collectionName);

        // Check if the product with the same name already exists in the products collection
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await productsCollectionRef
                .doc(userEmail)
                .collection('products')
                .where('name', isEqualTo: product.name)
                .where('imageUrl', isEqualTo: product.imageUrl)
                .get();

        bool productExists = querySnapshot.docs.isNotEmpty;

        if (!productExists) {
          // Convert the product object to a map
          Map<String, dynamic> productMap = product.toMap();

          // Save the data to Firestore using the user's email as the document ID in the products subcollection
          await productsCollectionRef
              .doc(userEmail)
              .collection('products')
              .add(productMap);

          print('Product data saved successfully!');
        } else {
          print(
              'Product with the same name and image already exists in the products collection.');
        }
      } catch (e) {
        print('Error saving product data: $e');
      }
    } else {
      print('User not logged in!');
    }
  }

  Future<int> fetchReviews(String name) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> productDocument =
          await FirebaseFirestore.instance
              .collection('comments')
              .doc(name)
              .get();

      if (productDocument.exists) {
        print(!productDocument.exists);
        print(name);
        print("Document NOt found");
        // If the document with the specified name doesn't exist, return 0 reviews
        return 0;
      }

      final CollectionReference<Map<String, dynamic>> usersCollection =
          productDocument.reference.collection('users');
      final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await usersCollection.get();
      debugPrint("Returning Snapshot");
      return usersSnapshot.size;
    } catch (e) {
      print('Error fetching reviews: $e');
      return 0;
    }
  }

Future<void> getImageUrlsFromFlask(String imageUrl) async {
  try {
    String flaskServerUrl = 'https://52c3-182-180-155-210.ngrok.io/get_similar_images'; // Replace with your Flask server URL

    // Create a JSON object with the image URL
    Map<String, dynamic> requestData = {'imageUrl': imageUrl}; // Change key to "imageUrl"

    // Send a POST request to the Flask server
    final response = await http.post(
      Uri.parse(flaskServerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Add this line
      List<dynamic> responseData = jsonDecode(response.body);

      // Assuming the response contains a list of product data and similarity scores
      responseData.forEach((product) {
        Map<String, dynamic> productData = product['product_data'];
        double similarityScore = product['similarity_score'];

        // Print the product data and similarity score
        print('Product Data: $productData');
        print('Similarity Score: $similarityScore');
      });
    } else {
      print('Failed to get data from Flask server. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting data from Flask server: $e');
  }
}



}
