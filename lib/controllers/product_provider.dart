import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/app_logger.dart';

/// Provider dedicado para manejar toda la lógica de productos
/// Gestiona la carga, creación, actualización y eliminación de productos
class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Constructor que inicializa el provider y configura listeners
  ProductProvider() {
    loadProducts();
    // Escuchar cambios en tiempo real de productos
    _productService.getProductsStream().listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga todos los productos desde el servicio
  Future<void> loadProducts() async {
    AppLogger.debug('[ProductProvider] Cargando productos');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[ProductProvider] Productos cargados exitosamente: ${_products.length} productos',
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('[ProductProvider] Error cargando productos', e);
    }
  }

  /// Agrega un nuevo producto al catálogo
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
  }) async {
    AppLogger.info('[ProductProvider] Agregando nuevo producto: $name');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final newProduct = Product.create(
        userId: userId,
        name: name,
        description: description,
        price: price,
        stock: stock,
      );

      await _productService.addProduct(newProduct);
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[ProductProvider] Producto agregado exitosamente: ${newProduct.id}',
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('[ProductProvider] Error agregando producto', e);
      return false;
    }
  }

  /// Actualiza un producto existente
  Future<bool> updateProduct(Product product) async {
    AppLogger.info('[ProductProvider] Actualizando producto: ${product.id}');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.updateProduct(product);
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[ProductProvider] Producto actualizado exitosamente: ${product.id}',
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('[ProductProvider] Error actualizando producto', e);
      return false;
    }
  }

  /// Elimina un producto del catálogo
  Future<bool> deleteProduct(String productId) async {
    AppLogger.info('[ProductProvider] Eliminando producto: $productId');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.deleteProduct(productId);
      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[ProductProvider] Producto eliminado exitosamente: $productId',
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('[ProductProvider] Error eliminando producto', e);
      return false;
    }
  }

  /// Limpia el mensaje de error actual
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
