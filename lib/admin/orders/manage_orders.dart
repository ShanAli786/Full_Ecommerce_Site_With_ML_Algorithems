// ignore_for_file: unused_local_variable, avoid_print, avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/admin/home/admin_home.dart';
import 'package:fashion_ecommerce_app/admin/orders/order_details.dart';

import 'package:flutter/material.dart';

import '../../model/admin/order_model_admin.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  List<CustomerOrders> customerOrders = [];

  Future<List<CustomerOrders>> fetchData() async {
    List<CustomerOrders> products = [];

    try {
      // Fetch all user emails from the "users" collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('OrdersForAdmin').get();
      debugPrint(snapshot.docs.length.toString());

      // Fetch orders for each user from the "orders" collection
      QuerySnapshot<Map<String, dynamic>> orderSnapshot =
          (await FirebaseFirestore.instance.collection('OrdersForAdmin').get());
      orderSnapshot.docs.forEach((orderDoc) {
        CustomerOrders product = CustomerOrders.fromMap(orderDoc.data());
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
        customerOrders = data;
        print("Customer Orders ${customerOrders.length}");
      });
    });
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
            "Customer Orders",
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AdminHome()));
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed table for the header
          FadeIn(
            delay: const Duration(milliseconds: 500),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Order#"),
                    Text("Detail"),
                    Text("No of Items"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: customerOrders.isEmpty
                ? Center(
                    child: FadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: const Text(
                        "No orders yet!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: customerOrders.length,
                    itemBuilder: (context, index) {
                      print(customerOrders.length.toString());
                      CustomerOrders order = customerOrders[index];

                      // Access the order properties
                      String orderNo = order.orderNo;
                      String customerName = order.userName;
                      String shippingAddress = order.shippingAddress;
                      int numberOfItems = order.quantity;
                      print(orderNo);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderDetails(
                                        imageUrl: order.itemPic,
                                        size: order.size,
                                        color: order.color,
                                        productName: order.productName,
                                        price: order.totalPrice,
                                        quantity: order.quantity,
                                        shippingAddress: order.shippingAddress,
                                        userEmail: order.userEmail,
                                        orderNo: order.orderNo,
                                      )));
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Text(orderNo),
                            title: Text(customerName),
                            subtitle: Text(shippingAddress),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(numberOfItems.toString()),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Order!'),
                                          content: const Text(
                                              'Are you sure to delete the order?'),
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
                                                Navigator.pop(context);
                                                deleteOrder(orderNo);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteOrder(String orderNo) async {
    try {
      // Find the index of the order to delete in the customerOrders list
      int index =
          customerOrders.indexWhere((order) => order.orderNo == orderNo);

      if (index != -1) {
        // Remove the order from the customerOrders list
        setState(() {
          customerOrders.removeAt(index);
        });

        // Delete the order from the database
        await FirebaseFirestore.instance
            .collection('OrdersForAdmin')
            .doc(orderNo)
            .delete();

        print('Order deleted successfully.');
      }
    } catch (e) {
      print('Error deleting order: $e');
    }
  }
}
