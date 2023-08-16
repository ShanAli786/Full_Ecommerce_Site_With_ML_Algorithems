// ignore_for_file: deprecated_member_use, avoid_print, avoid_function_literals_in_foreach_calls, prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/admin/products/add_product.dart';
import 'package:fashion_ecommerce_app/model/base_model.dart';
import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../model/categories_model.dart';
import '../../utils/constants.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  List<BaseModel> products = [];
  String selectedCategory = 'All';
  List<BaseModel> allProducts = []; // List to store all products
  List<BaseModel> kidsProducts = []; // List to store kids products
  List<BaseModel> menProducts = []; // List to store men products
  List<BaseModel> womenProducts = []; // List to store women products

  bool isSearchActive = false;
  // ignore: unused_field
  final int _index = 1;
  Set<Object> usedTags = {};

  @override
  void initState() {
    fetchData().then((data) {
      setState(() {
        products = data;
        updateCategoryProducts();
      });
    });
    super.initState();
  }

  void updateCategoryProducts() {
    allProducts = getProductsByCategory('all');
    kidsProducts = getProductsByCategory('kids');
    menProducts = getProductsByCategory('men');
    womenProducts = getProductsByCategory('women');
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      updateCategoryProducts();
    });
  }

  List<BaseModel> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return products;
    } else {
      return products
          .where((product) =>
              product.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
  }

  List<BaseModel> getCurrentProducts() {
    // Return the products based on the selected category
    if (selectedCategory.toLowerCase() == 'kids') {
      return kidsProducts;
    } else if (selectedCategory.toLowerCase() == 'men') {
      return menProducts;
    } else if (selectedCategory.toLowerCase() == 'women') {
      return womenProducts;
    }
    return allProducts;
  }

  SliverGridDelegate getGridDelegate() {
    // Return the grid delegate based on the selected category

    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.63,
    );
  }

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
              "Manage Products",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProduct(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      // Set the background color based on the button's state
                      if (states.contains(MaterialState.pressed)) {
                        return Colors
                            .orange[800]; // Color when the button is pressed
                      } else {
                        return Colors.orange; // Default color
                      }
                    },
                  ),
                ),
                child: const Text(
                  "Add New Item",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: size.width,
                  height: size.height * 0.14,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (ctx, index) {
                      CategoriesModel current = categories[index];
                      bool isSelected = selectedCategory == current.title;
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () {
                            onCategorySelected(current.title);
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: isSelected
                                      ? Colors.orange
                                      : Colors.transparent,
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundImage:
                                        AssetImage(current.imageUrl),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.008,
                                ),
                                Text(
                                  current.title,
                                  style: isSelected
                                      ? textTheme.subtitle1
                                          ?.copyWith(color: Colors.orange)
                                      : textTheme.subtitle1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 60),
              sliver: SliverGrid(
                gridDelegate: getGridDelegate(),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    BaseModel current = getCurrentProducts()[index];
                    Object tag = ObjectKey(current.id);
                    // Ensure the tag is unique
                    if (usedTags.contains(tag)) {
                      // Generate a new unique tag if there is a conflict
                      tag = ObjectKey('${current.id}_$index');
                    } else {
                      // Add the tag to the usedTags list
                      usedTags.add(tag);
                    }
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: GestureDetector(
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
                                top: 25,
                                right: 12,
                                child: PopupMenuButton<String>(
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'view',
                                        child: Text('View Detail'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ];
                                  },
                                  onSelected: (String value) {
                                    if (value == 'view') {
                                      // Handle view detail action
                                    } else if (value == 'edit') {
                                      // Handle edit action
                                      // Implement your logic here
                                    } else if (value == 'delete') {
                                      BaseModel selectedProduct =
                                          products[index];

                                      deleteProductByName(selectedProduct.name);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange,
                                    ),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.black,
                                    ),
                                  ),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: getCurrentProducts().length,
                ),
              ),
            ),
          ],
        ));
  }

  Future<List<BaseModel>> fetchData() async {
    List<BaseModel> fetchedProducts = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      fetchedProducts = snapshot.docs.map((doc) {
        return BaseModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print('Error fetching data: $e');
    }

    setState(() {
      products = fetchedProducts;
    });

    return fetchedProducts;
  }

  Future<void> deleteProductByName(String productName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (snapshot.size > 0) {
        // Assuming the name is unique, get the first document
        final documentId = snapshot.docs[0].id;

        // Delete the product from Firestore
        await FirebaseFirestore.instance
            .collection('products')
            .doc(documentId)
            .delete();

        // Remove the product from the list
        setState(() {
          products.removeWhere((product) => product.name == productName);
        });
      }
    } catch (error) {
      print('Error deleting product: $error');
    }
  }
}
