// ignore_for_file: avoid_print, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, body_might_complete_normally_catch_error, subtype_of_sealed_class

import 'package:fashion_ecommerce_app/screens/cart/cart.dart';
import 'package:fashion_ecommerce_app/screens/orders/my_orders.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';

import '../../main_wrapper.dart';
import '../../model/base_model.dart';
import '../../utils/constants.dart';
import '../category/category.dart';
import 'login.dart';

class UserAccount extends StatefulWidget {
  final String email;
  final String username;

  const UserAccount({
    Key? key,
    required this.email,
    required this.username,
  }) : super(key: key);

  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  bool showTickButton = false;
  late User? user;
  final int _index = 2;
  String userAddress =
      'Enter Your Shipping Address'; // Replace with user's address
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _updatedUsername = '';
  bool isUserLoggedIn = true;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    fetchUserShippingAddress();
  }

  Future<void> fetchUserShippingAddress() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          // If the user document exists, update the userAddress
          setState(() {
            userAddress = userSnapshot['shippingAddress'] ??
                'Enter Your Shipping Address';

            _addressController.text = userAddress;
            print('User address fetched: $userAddress');
          });
        } else {
          // If the user document does not exist, set the default userAddress
          setState(() {
            userAddress = 'Enter Your Shipping Address';
            _addressController.text = userAddress;
          });
        }
      } catch (e) {
        print('Error fetching user shipping address: $e');
      }
    }
  }

  void saveShippingAddress() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      // Check if the user is authenticated and has a valid user ID
      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Check if the user document exists
        DocumentSnapshot userSnapshot = await userDocRef.get();

        if (!userSnapshot.exists) {
          // If the document doesn't exist, create it with the required fields
          await userDocRef.set({
            'shippingAddress': userAddress,
            // Add other necessary fields here if needed
          });
        } else {
          // If the document already exists, update the 'shippingAddress' field
          await userDocRef.update({'shippingAddress': userAddress});
        }

        print('Shipping address saved successfully!');
      } catch (e) {
        print('Error saving shipping address: $e');
      }
    }
  }

  void captureImageFromCamera() async {
    Uint8List? img = await pickImage(ImageSource.camera);

    if (img != null) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        // Upload image to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
        UploadTask uploadTask = storageRef.putData(img);

        await uploadTask.whenComplete(() async {
          String imageUrl;
          try {
            imageUrl = await storageRef.getDownloadURL();
          } catch (error) {
            print('Error getting image URL: $error');
            // Handle the case where the image URL is not available
            imageUrl =
                'https://firebasestorage.googleapis.com/v0/b/smart-shopping-updated.appspot.com/o/login.png?alt=media&token=ef30b74e-fdcc-4ca8-a028-42eeaef74f63'; // Set a default or placeholder image URL
          }

          // Update user profile with image URL
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.updatePhotoURL(imageUrl);
          }

          setState(() {
            _image = img;
          });
        }).catchError((error) {
          print('Error uploading image: $error');
        });
      }
    }
  }

  Future<void> selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    if (img != null) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        // Upload image to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
        UploadTask uploadTask = storageRef.putData(img);

        await uploadTask.whenComplete(() async {
          String imageUrl;
          try {
            imageUrl = await storageRef.getDownloadURL();
          } catch (error) {
            print('Error getting image URL: $error');
            // Handle the case where the image URL is not available
            imageUrl =
                'https://firebasestorage.googleapis.com/v0/b/smart-shopping-updated.appspot.com/o/login.png?alt=media&token=ef30b74e-fdcc-4ca8-a028-42eeaef74f63'; // Set a default or placeholder image URL
          }

          // Update user profile with image URL
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.updatePhotoURL(imageUrl);
          }

          setState(() {
            _image = img;
          });
        }).catchError((error) {
          print('Error uploading image: $error');
        });
      }
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }

  Future<void> updateUserDisplayName(String displayName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(displayName);
        setState(() {
          _updatedUsername = displayName;
        });
        print('User name updated successfully!');
      } catch (e) {
        print('Error updating user name: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;
    bool isUserLoggedIn = true;
    const int x = 1;
    final List<BaseModel> products = [];

    return Scaffold(
      appBar: _buildAppBar(context, isUserLoggedIn),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _image != null
                          ? CircleAvatar(
                            backgroundColor: Colors.white,
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : user?.photoURL != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 64,
                                  backgroundImage:
                                      NetworkImage(user!.photoURL!),
                                )
                              : const CircleAvatar(
                                backgroundColor: Colors.white,
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                      "https://firebasestorage.googleapis.com/v0/b/smart-shopping-updated.appspot.com/o/login.png?alt=media&token=ef30b74e-fdcc-4ca8-a028-42eeaef74f63"),
                                ),
                      Positioned(
                        bottom: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap:
                              captureImageFromCamera, // Call your function to handle the camera icon tap
                          child: const CircleAvatar(
                            
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: GestureDetector(
                    onTap: selectImage,
                    child: const Text(
                      "Change Image",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 153, 0),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FadeIn(
                delay: const Duration(milliseconds: 700),
                child: Row(
                  children: [
                    Expanded(
                      child: isEditing
                          ? TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "Enter Name",
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditing = false;
                                          _nameController.clear();
                                        });
                                      },
                                      icon: const Icon(Icons.clear),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          _updatedUsername =
                                              _nameController.text;
                                          isEditing = false;
                                        });
                                        await updateUserDisplayName(
                                            _updatedUsername);
                                      },
                                      icon: const Icon(Icons.check),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              _updatedUsername.isNotEmpty
                                  ? _updatedUsername
                                  : widget.username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                          _nameController.text = widget.username;
                        });
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 900),
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeIn(
                delay: const Duration(milliseconds: 1100),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>
                                Cart(isUserLoggedIn: isUserLoggedIn))));
                  },
                  child: const Text(
                    "Shopping Cart",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 1300),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const MyOrders())));
                  },
                  child: const Text(
                    "My Orders",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const MyOrders())));
                  },
                  child: const Text(
                    "Give Feedback",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeIn(
                delay: const Duration(milliseconds: 1700),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        onChanged: (value) {
                          setState(() {
                            userAddress = value;
                            showTickButton = true;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: showTickButton
                              ? "Your Shipping Address"
                              : "Your Shipping Address",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (showTickButton)
                      IconButton(
                        onPressed: () {
                          saveShippingAddress(); // Save the address
                          setState(() {
                            showTickButton = false;
                          });
                          FocusScope.of(context)
                              .unfocus(); // Close the field (hide keyboard)
                        },
                        icon: const Icon(Icons.check),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: FadeIn(
                  delay: const Duration(milliseconds: 1900),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 131, 54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 10),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((_) {
                        // Log out successful, navigate to login screen
                        Navigator.pushReplacement(
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
                                  )),
                        );
                      }).catchError((error) {
                        // Handle logout error if necessary
                        print('Logout error: $error');
                      });
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                    MainWrapper(isUserLoggedIn: isUserLoggedIn),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  isUserLoggedIn: isUserLoggedIn,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isUserLoggedIn) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Manage My Account",
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
                      const CategoryScreen(isUserLoggedIn: true)));
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
