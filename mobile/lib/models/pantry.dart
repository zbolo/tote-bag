import 'pantry_item.dart';
import 'storage_location.dart';
import 'user.dart';

class Pantry {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final User owner;
  final List<PantryItem> items;
  final List<StorageLocation> storageLocations;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  Pantry({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.owner,
    required this.items,
    required this.storageLocations,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory Pantry.fromJson(Map<String, dynamic> json) {
    return Pantry(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (item) => PantryItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      storageLocations: (json['storageLocations'] as List<dynamic>?)
              ?.map((loc) =>
                  StorageLocation.fromJson(loc as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'owner': owner.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'storageLocations':
          storageLocations.map((loc) => loc.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  Pantry copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    User? owner,
    List<PantryItem>? items,
    List<StorageLocation>? storageLocations,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Pantry(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      owner: owner ?? this.owner,
      items: items ?? this.items,
      storageLocations: storageLocations ?? this.storageLocations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  int get totalItems => items.length;

  int get expiringItemCount =>
      items.where((item) => item.isExpiringSoon(7)).length;

  int get expiredItemCount => items.where((item) => item.isExpired).length;

  int get lowStockItemCount => items.where((item) => item.isLowStock).length;

  /// Group items by storage location
  Map<StorageLocation?, List<PantryItem>> get itemsByLocation {
    final map = <StorageLocation?, List<PantryItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.storageLocation, () => []).add(item);
    }
    return map;
  }
}
