import 'product.dart';
import 'storage_location.dart';

class PantryItem {
  final String id;
  final String name;
  final double quantity;
  final double maxQuantity;
  final String? unit;
  final String? category;
  final StorageLocation? storageLocation;
  final Product? product;
  final String? barcode;
  final String? notes;
  final DateTime? expirationDate;
  final DateTime? purchaseDate;
  final double? price;
  final double? contentQuantity;
  final double? contentMaxQuantity;
  final String? contentUnit;
  final double lowStockThreshold;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  PantryItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.maxQuantity = 1,
    this.unit,
    this.category,
    this.storageLocation,
    this.product,
    this.barcode,
    this.notes,
    this.expirationDate,
    this.purchaseDate,
    this.price,
    this.contentQuantity,
    this.contentMaxQuantity,
    this.contentUnit,
    this.lowStockThreshold = 0.25,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      maxQuantity: (json['maxQuantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      storageLocation: json['storageLocation'] != null
          ? StorageLocation.fromJson(
              json['storageLocation'] as Map<String, dynamic>)
          : null,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      barcode: json['barcode'] as String?,
      notes: json['notes'] as String?,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      price: (json['price'] as num?)?.toDouble(),
      contentQuantity: (json['contentQuantity'] as num?)?.toDouble(),
      contentMaxQuantity: (json['contentMaxQuantity'] as num?)?.toDouble(),
      contentUnit: json['contentUnit'] as String?,
      lowStockThreshold:
          (json['lowStockThreshold'] as num?)?.toDouble() ?? 0.25,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'maxQuantity': maxQuantity,
      'unit': unit,
      'category': category,
      'storageLocation': storageLocation?.toJson(),
      'product': product?.toJson(),
      'barcode': barcode,
      'notes': notes,
      'expirationDate': expirationDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'price': price,
      'contentQuantity': contentQuantity,
      'contentMaxQuantity': contentMaxQuantity,
      'contentUnit': contentUnit,
      'lowStockThreshold': lowStockThreshold,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PantryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    double? maxQuantity,
    String? unit,
    String? category,
    StorageLocation? storageLocation,
    Product? product,
    String? barcode,
    String? notes,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    double? price,
    double? contentQuantity,
    double? contentMaxQuantity,
    String? contentUnit,
    double? lowStockThreshold,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      storageLocation: storageLocation ?? this.storageLocation,
      product: product ?? this.product,
      barcode: barcode ?? this.barcode,
      notes: notes ?? this.notes,
      expirationDate: expirationDate ?? this.expirationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      price: price ?? this.price,
      contentQuantity: contentQuantity ?? this.contentQuantity,
      contentMaxQuantity: contentMaxQuantity ?? this.contentMaxQuantity,
      contentUnit: contentUnit ?? this.contentUnit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether content-level tracking is enabled
  bool get hasContentTracking =>
      contentMaxQuantity != null && contentMaxQuantity! > 0;

  /// Quantity as a percentage (0.0 - 1.0).
  /// Uses content quantities when available, falls back to piece quantities.
  double get quantityPercentage {
    if (hasContentTracking) {
      return ((contentQuantity ?? 0) / contentMaxQuantity!).clamp(0.0, 1.0);
    }
    return maxQuantity > 0 ? (quantity / maxQuantity).clamp(0.0, 1.0) : 0.0;
  }

  /// The current slider value (content quantity or piece quantity)
  double get sliderValue =>
      hasContentTracking ? (contentQuantity ?? 0) : quantity;

  /// The max slider value (content max or piece max)
  double get sliderMax =>
      hasContentTracking ? contentMaxQuantity! : maxQuantity;

  /// Whether the item is running low
  bool get isLowStock {
    if (hasContentTracking) {
      return (contentQuantity ?? 0) <=
          lowStockThreshold * contentMaxQuantity!;
    }
    return quantity <= lowStockThreshold * maxQuantity;
  }

  /// Whether the item has expired
  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  /// Whether the item expires within N days
  bool isExpiringSoon(int days) {
    if (expirationDate == null) return false;
    final deadline = DateTime.now().add(Duration(days: days));
    return expirationDate!.isBefore(deadline) &&
        !expirationDate!.isBefore(DateTime.now());
  }

  /// Days until expiration (negative = already expired)
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  /// Display piece quantity with unit (e.g. "2 pcs")
  String get displayQuantity {
    final qty = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    if (unit != null) {
      return '$qty $unit';
    }
    return qty;
  }

  /// Display content quantity with unit (e.g. "350 g")
  String? get displayContentQuantity {
    if (!hasContentTracking) return null;
    final qty = contentQuantity ?? 0;
    final fmtQty =
        qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1);
    final fmtMax = contentMaxQuantity! % 1 == 0
        ? contentMaxQuantity!.toInt().toString()
        : contentMaxQuantity!.toStringAsFixed(1);
    final u = contentUnit ?? '';
    return '$fmtQty / $fmtMax $u'.trim();
  }
}
