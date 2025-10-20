import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final double price;
  @HiveField(5)
  final int stock;
  @HiveField(6)
  final DateTime createdAt;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.createdAt,
  });

  // Factory constructor para crear desde JSON (Supabase)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : DateTime.tryParse(json['created_at']?.toString() ?? '') ??
                DateTime.now(),
    );
  }

  // Método para convertir a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Constructor para crear producto nuevo (sin ID y createdAt)
  factory Product.create({
    required String userId,
    required String name,
    required String description,
    required double price,
    required int stock,
  }) {
    return Product(
      id: '', // Se generará en BD
      userId: userId,
      name: name,
      description: description,
      price: price,
      stock: stock,
      createdAt: DateTime.now(),
    );
  }

  // CopyWith para actualizaciones
  Product copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? price,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
