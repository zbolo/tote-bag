import 'product.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final String? notes;
  final bool isChecked;
  final String? category;
  final Product? product;
  final String? barcode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? checkedAt;
  final int order;

  ShoppingListItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.unit,
    this.notes,
    this.isChecked = false,
    this.category,
    this.product,
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
    this.checkedAt,
    this.order = 0,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    // Product can be a full object (Map) or a bare UUID string (unpopulated
    // MikroORM reference). Only parse when we receive a full object.
    final rawProduct = json['product'];
    final Product? product =
        rawProduct is Map<String, dynamic> ? Product.fromJson(rawProduct) : null;

    return ShoppingListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      isChecked: json['isChecked'] as bool? ?? false,
      category: json['category'] as String?,
      product: product,
      barcode: json['barcode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      checkedAt: json['checkedAt'] != null
          ? DateTime.parse(json['checkedAt'] as String)
          : null,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'isChecked': isChecked,
      'category': category,
      'product': product?.toJson(),
      'barcode': barcode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'checkedAt': checkedAt?.toIso8601String(),
      'order': order,
    };
  }

  ShoppingListItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    String? notes,
    bool? isChecked,
    String? category,
    Product? product,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? checkedAt,
    int? order,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
      product: product ?? this.product,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      checkedAt: checkedAt ?? this.checkedAt,
      order: order ?? this.order,
    );
  }

  String get displayQuantity {
    if (unit != null) {
      return '$quantity $unit';
    }
    return quantity.toString();
  }
}
