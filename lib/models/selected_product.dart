import 'package:hive/hive.dart';
import '../models/product_model.dart';

part 'selected_product.g.dart';

@HiveType(typeId: 1)
class SelectedProduct {
  @HiveField(0)
  final Product product;
  @HiveField(1)
  double unitPrice; // Precio unitario editable (con IVA incluido)
  @HiveField(2)
  int quantity; // Cantidad editable

  SelectedProduct({
    required this.product,
    required this.unitPrice,
    required this.quantity,
  });

  // Precio sin IVA calculado (unitPrice / 1.19)
  double get priceWithoutIva =>
      double.parse((unitPrice / 1.19).toStringAsFixed(2));

  // Total por item (unitPrice * quantity)
  double get total => unitPrice * quantity;

  // Crear copia con cambios
  SelectedProduct copyWith({
    Product? product,
    double? unitPrice,
    int? quantity,
  }) {
    return SelectedProduct(
      product: product ?? this.product,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  factory SelectedProduct.fromJson(Map<String, dynamic> json) {
    if (json['product'] == null) {
      // Si el producto es null, crear un producto dummy para evitar errores
      final dummyProduct = Product(
        id: 'unknown',
        userId: 'unknown',
        name: 'Producto desconocido',
        description: 'Producto no encontrado',
        price: 0.0,
        stock: 0,
        createdAt: DateTime.now(),
      );
      return SelectedProduct(
        product: dummyProduct,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
        quantity: json['quantity'] as int? ?? 0,
      );
    }
    return SelectedProduct(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }
}
