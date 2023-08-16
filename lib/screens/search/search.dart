// ignore_for_file: deprecated_member_use, avoid_function_literals_in_foreach_calls, avoid_print, unused_label, prefer_final_fields, unused_local_variable




import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:speech_to_text/speech_to_text.dart';



import '../../model/base_model.dart';
import '../../utils/constants.dart';
import '../../widget/add_to_cart.dart';
import '../../data/app_data.dart';
import '../LogInSignUp/login.dart';
import '../ProductDetail/details.dart';






class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
} 

class _SearchState extends State<Search> {
  late TextEditingController controller;
  List<BaseModel> products = [];
  bool isUserLoggedIn = false;
  // Uint8List? _image;
  final ImagePicker _imagePicker = ImagePicker();

  SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    itemsOnSearch = products;
    checkUserLoggedIn().then((isLoggedIn) {
      setState(() {
        isUserLoggedIn = isLoggedIn;
      });
    });
    fetchData().then((data) {
      setState(() {
        products = data;
      });
    });
  }

Future<void> captureImageFromCamera() async {
  Uint8List? img = await pickImage(ImageSource.camera);

  if (img != null) {
   
  }
}
  Future<Uint8List?> pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              controller.text = _recognizedText;
              onSearch(_recognizedText);
            });
          },
        );
        setState(() {
          _isListening = true;
        });
      }
    } else {
      debugPrint('Not Worked');
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  // Searching Function for TextField
  onSearch(String search) {
    setState(() {
      itemsOnSearch = products
          .where((element) => element.name.toLowerCase().contains(search))
          .toList();
    });
  }

  Future<bool> checkUserLoggedIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser != null;
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    int selectedSize = 1;
    int selectedColor = 1;
    const int x = 1;
    const bool isCameFromLogIn = false;

    return Material(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: WillPopScope(
          onWillPop: () async {
            controller.clear();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    // Search Box
                    FadeInUp(
                      delay: const Duration(milliseconds: 50),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.03),
                        child: SizedBox(
                          width: size.width,
                          height: size.height * 0.07,
                          child: Center(
                            child: TextField(
                              controller: controller,
                              onChanged: (value) {
                                onSearch(value);
                              },
                              style: textTheme.headline3?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 20,
                                ),
                                filled: true,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: _listen,
                                      icon: Icon(_isListening
                                          ? Icons.mic
                                          : Icons.mic_none),
                                    ),
                                    IconButton(
                                        onPressed: captureImageFromCamera,
                                        icon: const Icon(
                                          Icons.camera_alt,
                                        )),
                                    IconButton(
                                      onPressed: () {
                                        controller.clear();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        setState(() {
                                          itemsOnSearch = products;
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                                hintStyle: textTheme.headline3?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                                hintText: "e.g. Casual Jeans",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: size.height * 0.01,
                    ),

                    /// Main Item List For Searching
                    Expanded(
                      child: itemsOnSearch.isNotEmpty
                          ? GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: itemsOnSearch.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.63,
                              ),
                              itemBuilder: (context, index) {
                                BaseModel current = itemsOnSearch[index];
                                return FadeInUp(
                                  delay: Duration(milliseconds: 100 * index),
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          return Details(
                                            data: current,
                                            isCameFromMostPopularPart: false,
                                            isUserLoggedIn: isUserLoggedIn,
                                            isCameFromLogIn: isCameFromLogIn,
                                            fromWhere: 1,
                                          );
                                        },
                                      ),
                                    ),
                                    child: Hero(
                                      tag: '${current.id}_$index',
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
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      current.imageUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    offset: Offset(0, 4),
                                                    blurRadius: 4,
                                                    color: Color.fromARGB(
                                                        61, 0, 0, 0),
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
                                                style: textTheme.subtitle2
                                                    ?.copyWith(
                                                  color: primaryColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: current.price
                                                        .toString(),
                                                    style: textTheme.subtitle2
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      selectedColor,
                                                      selectedSize,
                                                    );
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Login Required'),
                                                          content: const Text(
                                                              'Please log in to add items to your cart.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .orange),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Login(
                                                                              x: x,
                                                                              fromWhere: 0,
                                                                              data: products.isNotEmpty ? products[0] : BaseModel(id: 1, imageUrl: "imageUrl", name: "name", category: "category", price: 1.0, review: 1.2, value: 1, selectedSize: 1, selectedColor: 1),
                                                                            ))); // Close the dialog
                                                              },
                                                              child: const Text(
                                                                'Log In',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .orange),
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
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: size.height * 0.02,
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 200),
                                  child: const Image(
                                    image: AssetImage(
                                        "assets/images/search_fail.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                FadeInUp(
                                  delay: const Duration(milliseconds: 250),
                                  child: const Text(
                                    "No Result Found :(",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
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
}
