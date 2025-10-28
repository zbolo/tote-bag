class Product {
  final String id;
  final String barcode;
  final String name;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String? category;
  final String? quantity;
  final Map<String, dynamic>? nutritionData;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand,
    this.description,
    this.imageUrl,
    this.category,
    this.quantity,
    this.nutritionData,
    this.source = 'openfoodfacts',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      quantity: json['quantity'] as String?,
      nutritionData: json['nutritionData'] as Map<String, dynamic>?,
      source: json['source'] as String? ?? 'openfoodfacts',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'quantity': quantity,
      'nutritionData': nutritionData,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (brand != null) {
      return '$brand - $name';
    }
    return name;
  }
}
