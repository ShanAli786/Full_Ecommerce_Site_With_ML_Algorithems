// ignore_for_file: deprecated_member_use, await_only_futures, avoid_print, unused_local_variable, dead_code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/admin/orders/manage_orders.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OrderDetails extends StatefulWidget {
  final String imageUrl;
  final String productName;
  final int size;
  final int color;
  final String shippingAddress;
  final String userEmail;
  final int quantity;
  final double price;
  final String orderNo;

  const OrderDetails({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.size,
    required this.color,
    required this.shippingAddress,
    required this.userEmail,
    required this.quantity,
    required this.price,
    required this.orderNo,
  }) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    bool isConfirmed = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontSize: 22, // Larger heading font size
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 370,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Serif",
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                const Text(
                  "Shipping Address: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.shippingAddress,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quantity:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Size:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    getSizeAsString(widget.size),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Color:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    getColorAsString(widget.color),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "\$${widget.price}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Add other product details here...
            const SizedBox(height: 32),
            Row(children: [
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Order!'),
                        content:
                            const Text('Are you sure to delete the order?'),
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
                              deleteOrder(widget.orderNo);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageOrders()));
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      );
                    },
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    'Delete Order',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  sendEmail(widget.userEmail).then((sent) {
                    if (sent) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Order Confirmation!'),
                            content: const Text(
                                'An email has been sent to the customer email address.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Order Confirmation!'),
                            content: const Text(
                                'Failed to send the order confirmation email.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    'Confirm Order',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String getSizeAsString(int index) {
    switch (index) {
      case 0:
        return "Small";
      case 1:
        return "Medium";
      case 2:
        return "Large";
      case 3:
        return "Extra Large";
      case 4:
        return "XXL";
      default:
        return "N/A";
    }
  }

  String getColorAsString(int index) {
    switch (index) {
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

  Future<bool> sendEmail(String userEmail) async {
    String username = 'alishan3331212112@gmail.com';
    String password = 'lzfwfoxqawgjfyeo';
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Smart Shopping')
      ..recipients.add(userEmail)
      ..subject = 'Order Confirmation!'
      ..text = 'Your order is on the way. Thank you for shopping with us!';

    try {
      final sendReport = await send(message, smtpServer);

      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  Future<void> deleteOrder(String orderNo) async {
    try {
      await FirebaseFirestore.instance
          .collection('OrdersForAdmin')
          .doc(orderNo)
          .delete();

      print('Order deleted successfully.');
    } catch (e) {
      print('Error deleting order: $e');
    }
  }
}
