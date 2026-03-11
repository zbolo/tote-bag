import 'shopping_list_item.dart';
import 'user.dart';

class ShoppingList {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final User owner;
  final List<ShoppingListItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  ShoppingList({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.owner,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    // Owner can be a full object or a bare UUID string (unpopulated reference).
    final rawOwner = json['owner'];
    final owner = rawOwner is Map<String, dynamic>
        ? User.fromJson(rawOwner)
        : User(
            id: rawOwner?.toString() ?? '',
            email: '',
            displayName: 'Unknown',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    // Items may contain unpopulated references — only parse Maps.
    final rawItems = json['items'] as List<dynamic>?;
    final items = rawItems
            ?.whereType<Map<String, dynamic>>()
            .map((item) => ShoppingListItem.fromJson(item))
            .toList() ??
        [];

    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      owner: owner,
      items: items,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  ShoppingList copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    User? owner,
    List<ShoppingListItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      owner: owner ?? this.owner,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  int get totalItems => items.length;
  int get checkedItems => items.where((item) => item.isChecked).length;
  double get progress => totalItems > 0 ? checkedItems / totalItems : 0.0;
}
