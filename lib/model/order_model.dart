// ignore_for_file: unnecessary_null_comparison

class RecentOrder {
  final String orderNo;
  final String itemPic;
  final int quantity;
  final double totalPrice;
  final int color;
  final int size;

  RecentOrder({
    required this.color,
    required this.size,
    required this.orderNo,
    required this.itemPic,
    required this.quantity,
    required this.totalPrice,
  }) : assert(itemPic != null);

  // Factory constructor to create a RecentOrder object from a map of data
  factory RecentOrder.fromMap(Map<String, dynamic> map) {
    return RecentOrder(
      orderNo: map['orderNo'] as String? ?? "",
      itemPic: map['imageUrl'] as String? ?? "",
      quantity: map['value'] as int? ?? 0,
      totalPrice: (map['price'] as num? ?? 0.0).toDouble(),
      color: map['selectedColor'] as int? ?? 0,
      size: map['selectedSize'] as int? ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'orderNo': orderNo,
      'imageUrl': itemPic,
      'value': quantity,
      'price': totalPrice,
      'selectedColor': color,
      'selectedSize': size,
    };
  }
}
