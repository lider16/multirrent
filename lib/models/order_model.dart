import 'dart:convert';
import 'package:hive/hive.dart';
import 'selected_product.dart';

part 'order_model.g.dart';

enum OrderStatus { quote, sale, saleWithInvoice }

@HiveType(typeId: 2)
class OrderModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final int statusIndex; // Guardar como int para Hive
  @HiveField(3)
  final List<SelectedProduct> products;
  @HiveField(4)
  final double total;
  @HiveField(5)
  final DateTime? createdAt;
  @HiveField(6)
  final DateTime? updatedAt; // Nuevo campo para sincronización
  @HiveField(7)
  final int syncVersion; // Nuevo campo para versionado
  @HiveField(8)
  final bool isSynced; // Nuevo campo para estado de sincronización
  @HiveField(9)
  final String? supabaseId; // ID de Supabase para mapear

  // Getter para obtener el enum desde el índice
  OrderStatus get status => OrderStatus.values[statusIndex];

  // Método auxiliar para parsear productos (maneja tanto List como String JSON)
  static List<SelectedProduct> _parseProducts(dynamic productsData) {
    if (productsData == null) return [];

    try {
      // Si es una lista (formato nuevo)
      if (productsData is List) {
        return productsData
            .where((item) => item != null) // Filtrar nulls
            .map((item) {
              try {
                return SelectedProduct.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Error parseando producto individual: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<SelectedProduct>()
            .toList();
      }

      // Si es un string JSON (formato antiguo)
      if (productsData is String) {
        final List<dynamic> parsedList = jsonDecode(productsData);
        return parsedList
            .where((item) => item != null) // Filtrar nulls
            .map((item) {
              try {
                return SelectedProduct.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Error parseando producto individual: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<SelectedProduct>()
            .toList();
      }

      // Si no es ninguno de los formatos esperados
      return [];
    } catch (e) {
      print('Error parseando productos: $e');
      return [];
    }
  }

  const OrderModel._({
    this.id,
    required this.userId,
    required this.statusIndex,
    required this.products,
    required this.total,
    this.createdAt,
    this.updatedAt,
    required this.syncVersion,
    required this.isSynced,
    this.supabaseId,
  });

  // Constructor público que acepta statusIndex
  factory OrderModel({
    String? id,
    required String userId,
    required int statusIndex,
    required List<SelectedProduct> products,
    required double total,
    DateTime? createdAt,
    DateTime? updatedAt,
    int syncVersion = 1,
    bool isSynced = false,
    String? supabaseId,
  }) {
    return OrderModel._(
      id: id,
      userId: userId,
      statusIndex: statusIndex,
      products: products,
      total: total,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncVersion: syncVersion,
      isSynced: isSynced,
      supabaseId: supabaseId,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Manejar el campo status de manera segura
    String statusString = json['status'] as String? ?? 'quote';
    int statusIndex;
    try {
      statusIndex = OrderStatus.values
          .firstWhere((e) => e.toString().split('.').last == statusString)
          .index;
    } catch (e) {
      // Si el status no es válido, usar 'quote' por defecto
      statusIndex = OrderStatus.quote.index;
    }

    return OrderModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      statusIndex: statusIndex,
      products: _parseProducts(json['products']),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      syncVersion: json['sync_version'] as int? ?? 1,
      isSynced:
          json['is_synced'] as bool? ??
          true, // Las órdenes de Supabase ya están sincronizadas
      supabaseId:
          json['id']
              as String?, // El ID de Supabase es el mismo que el campo 'id'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'status': status.toString().split('.').last,
      'products': products.map((item) => item.toJson()).toList(),
      'total': total,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'sync_version': syncVersion,
      'is_synced': isSynced,
      if (supabaseId != null) 'supabase_id': supabaseId,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    int? statusIndex,
    List<SelectedProduct>? products,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncVersion,
    bool? isSynced,
    String? supabaseId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      statusIndex: statusIndex ?? this.statusIndex,
      products: products ?? this.products,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      isSynced: isSynced ?? this.isSynced,
      supabaseId: supabaseId ?? this.supabaseId,
    );
  }
}
