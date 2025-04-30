class Product {
  final String id;
  final String name;
  final double price;
  final double gstRate; // 5, 12, 18, or 28

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.gstRate,
  });

  // Convert to and from JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'gstRate': gstRate,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    gstRate: json['gstRate'],
  );
}
