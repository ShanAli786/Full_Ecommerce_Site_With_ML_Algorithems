class BaseModel {
  final int id;
  final String imageUrl;
  final String name;
  final String category;
  final double price;
  double review;
  late int value;
  late int selectedSize;
  late int selectedColor;

  BaseModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.price,
    required this.review,
    required this.value,
    required this.selectedSize,
    required this.selectedColor,
  });

  factory BaseModel.fromMap(Map<String, dynamic> map) {
    return BaseModel(
      id: map['id'] as int,
      imageUrl: map['imageUrl'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      review: (map['review'] as num).toDouble(),
      value: map['value'] as int,
      selectedSize: map['selectedSize'] as int,
      selectedColor: map['selectedColor'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'category': category,
      'price': price,
      'review': review,
      'value': value,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }
}
