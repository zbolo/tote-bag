import 'package:flutter/material.dart';

class StorageLocation {
  final String id;
  final String name;
  final String icon;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  StorageLocation({
    required this.id,
    required this.name,
    this.icon = 'inventory_2',
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) {
    return StorageLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'inventory_2',
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StorageLocation copyWith({
    String? id,
    String? name,
    String? icon,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StorageLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Map icon string names to Material Icons
  IconData get iconData {
    switch (icon) {
      case 'kitchen':
        return Icons.kitchen;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'shelves':
        return Icons.shelves;
      case 'warehouse':
        return Icons.warehouse;
      case 'inventory_2':
        return Icons.inventory_2;
      default:
        return Icons.inventory_2;
    }
  }
}
