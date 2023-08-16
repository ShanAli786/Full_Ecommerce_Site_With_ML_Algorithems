// ignore_for_file: avoid_print, unused_local_variable, deprecated_member_use, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/data/app_data.dart';
import 'package:fashion_ecommerce_app/model/base_model.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  List<BaseModel> productList = mainList;

  bool isRecommended = false;
  bool isPopular = false;
  final nameController = TextEditingController();
  final imageUrlController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final reviewController = TextEditingController();
  final starController = TextEditingController();
  final idController = TextEditingController();
  final valueController = TextEditingController();
  final recommendedController = ValueNotifier<bool>(false);
  final popularController = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
  }
  // File? _image;

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedImage = await picker.getImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (pickedImage != null) {
  //       _image = File(pickedImage.path);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

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
            "Add New Product",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image Url'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: reviewController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Review'),
            ),

            TextField(
              controller: idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value'),
            ),

            // ElevatedButton(
            //   onPressed: _pickImage,
            //   child: const Text('Select Image'),
            // ),
            // if (_image != null)
            //   SizedBox(
            //     height: size.height * 0.3,
            //     child: Image.file(_image!),
            //   ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                if (validateFields()) {
                  final product = BaseModel(
                    name: nameController.text,
                    imageUrl: imageUrlController.text,
                    category: categoryController.text,
                    price: double.parse(priceController.text),
                    review: double.parse(reviewController.text),
                    id: int.parse(idController.text),
                    value: int.parse(valueController.text),
                    selectedColor: 1,
                    selectedSize: 1,
                  );
                  await createProduct(product);
                  clearFields();
                  showSuccessMessage();
                } else {
                  showErrorMessage();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createProduct(BaseModel product) async {
    try {
      final updatedProduct = BaseModel(
        id: product.id,
        imageUrl: product.imageUrl,
        name: product.name,
        category: product.category,
        price: product.price,
        review: product.review,
        value: product.value,
        selectedSize: 1, // Set default value for selectedSize
        selectedColor: 1, // Set default value for selectedColor
      );

      await FirebaseFirestore.instance
          .collection('products')
          .add(updatedProduct.toMap());

      // Product created successfully
      // You can show a success message or navigate to another screen
      // after successfully creating the product
      print('Product created successfully');
    } catch (e) {
      // Error occurred while creating the product
      // You can handle the error as per your requirement
      print('Error creating product: $e');
    }
  }

  void clearFields() {
    nameController.clear();
    imageUrlController.clear();
    categoryController.clear();
    priceController.clear();
    reviewController.clear();
    idController.clear();
    valueController.clear();
  }

  void showSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Product added successfully.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool validateFields() {
    if (nameController.text.isEmpty ||
        imageUrlController.text.isEmpty ||
        categoryController.text.isEmpty ||
        priceController.text.isEmpty ||
        reviewController.text.isEmpty ||
        idController.text.isEmpty ||
        valueController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something\'s Missing'),
        content: const Text('Please fill all the required fields.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
