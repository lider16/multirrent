import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/selected_product.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener productos del usuario actual
  Future<List<Product>> getProducts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('productos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  // Agregar nuevo producto
  Future<Product> addProduct(Product product) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final productData = product.copyWith(userId: userId).toJson();
      productData.remove('id'); // Remover ID para que se genere automáticamente
      productData.remove(
        'created_at',
      ); // Remover created_at para que se genere automáticamente

      final response = await _supabase
          .from('productos')
          .insert(productData)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  // Actualizar producto
  Future<Product> updateProduct(Product product) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final productData = product.toJson();
      productData.remove('created_at'); // No actualizar created_at

      final response = await _supabase
          .from('productos')
          .update(productData)
          .eq('id', product.id)
          .eq(
            'user_id',
            userId,
          ) // Asegurar que solo actualice productos propios
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  // Eliminar producto
  Future<void> deleteProduct(String productId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .from('productos')
          .delete()
          .eq('id', productId)
          .eq('user_id', userId); // Asegurar que solo elimine productos propios
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // Obtener ID del usuario actual
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Stream de productos para actualizaciones en tiempo real
  Stream<List<Product>> getProductsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('productos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Product.fromJson(json)).toList());
  }

  // Crear cotización
  Future<OrderModel> createQuote(
    List<SelectedProduct> products,
    double total,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final orderData = {
        'user_id': userId,
        'status': 'quote',
        'products': products.map((p) => p.toJson()).toList(),
        'subtotal': total,
        'discount': 0.0,
        'total': total,
        'date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('quotes')
          .insert(orderData)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear cotización: $e');
    }
  }

  // Crear venta
  Future<OrderModel> createSale(
    List<SelectedProduct> products,
    double total,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final orderData = {
        'user_id': userId,
        'status': 'sale',
        'products': products.map((p) => p.toJson()).toList(),
        'subtotal': total,
        'discount': 0.0,
        'total': total,
        'date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('quotes')
          .insert(orderData)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear venta: $e');
    }
  }

  // Crear venta con factura
  Future<OrderModel> createSaleWithInvoice(
    List<SelectedProduct> products,
    double total,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final orderData = {
        'user_id': userId,
        'status': 'sale_with_invoice',
        'products': products.map((p) => p.toJson()).toList(),
        'subtotal': total,
        'discount': 0.0,
        'total': total,
        'date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('quotes')
          .insert(orderData)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear venta con factura: $e');
    }
  }

  // Obtener historial de pedidos
  Future<List<OrderModel>> getOrderHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('quotes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }

  // Eliminar orden
  Future<void> deleteOrder(String orderId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .from('quotes')
          .delete()
          .eq('id', orderId)
          .eq('user_id', userId); // Asegurar que solo elimine órdenes propias
    } catch (e) {
      throw Exception('Error al eliminar orden: $e');
    }
  }
}
