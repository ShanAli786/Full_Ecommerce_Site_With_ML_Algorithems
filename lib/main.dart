// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../utils/app_theme.dart';
import 'admin/home/admin_home.dart';
import 'main_wrapper.dart';
import 'model/base_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey =
      "pk_test_51NSDXeFhFNOnKMY7ATVTt1fYvaFx4Yv4DmErHR1wDVI1ixWLihD1d5m5znQMTDV4a6tg0fAD0UYSO6EDoSU9Ba1N00kJVuHfUA";

  bool isUserLoggedIn = await checkUserLoggedIn();
  updatePopularProducts();
  FirebaseAuth auth = FirebaseAuth.instance;

  runApp(
    MaterialApp(
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      home: auth.currentUser?.email == 'admin.smart@gmail.com'
          ? const AdminHome()
          : MainWrapper(isUserLoggedIn: isUserLoggedIn),
    ),
  );
}

Future<bool> checkUserLoggedIn() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  return auth.currentUser != null;
}

Future<void> updatePopularProducts() async {
  List<BaseModel> products = [];

  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    snapshot.docs.forEach((doc) {
      BaseModel product = BaseModel.fromMap(doc.data());
      products.add(product);
    });

    for (int i = 0; i < products.length; i++) {
      final String productName = products[i].name;

      // Query "comments" collection to get the reviews count for the current product
      final QuerySnapshot<Map<String, dynamic>> reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('comments')
              .doc(productName)
              .collection('users')
              .get();

      final int reviewsCount = reviewsSnapshot.size;

      // Update the 'review' property of the current product with the reviews count
      products[i].review = reviewsCount.toDouble();
    }

    // Sort products based on reviews count in descending order
    products.sort((a, b) => b.review.compareTo(a.review));

    // Save only the top 10 products to the "PopularProducts" collection
    final CollectionReference<Map<String, dynamic>> popularProductsCollection =
        FirebaseFirestore.instance.collection('PopularProducts');

    // Clear the existing documents in the "PopularProducts" collection
    await popularProductsCollection.get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    int count = products.length < 10 ? products.length : 10;

    for (int i = 0; i < count; i++) {
      await popularProductsCollection.doc().set(products[i].toMap());
    }

    print('PopularProducts collection updated successfully.');
  } catch (e) {
    print('Error updating PopularProducts collection: $e');
  }
}
