import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/selected_product.dart';
import '../services/product_service.dart';
import '../services/local_storage_service.dart';
import '../services/deduplication_service.dart';
import '../services/sync_service.dart';
import '../services/app_logger.dart';

/// Provider dedicado para manejar toda la lógica de órdenes
/// Gestiona la creación, eliminación, carga y sincronización de órdenes
class OrderProvider with ChangeNotifier {
  final ProductService _productService;
  final LocalStorageService _localStorage;
  final DeduplicationService _deduplicationService;
  final SyncService _syncService;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isLocalStorageInitialized = false;
  String? _errorMessage;

  /// Constructor que requiere los servicios necesarios
  OrderProvider(
    this._productService,
    this._localStorage,
    this._deduplicationService,
    this._syncService,
  ) {
    _initLocalStorage();
  }

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicializa el almacenamiento local
  Future<void> _initLocalStorage() async {
    try {
      await _localStorage.init();
      _isLocalStorageInitialized = true;
    } catch (e) {
      _errorMessage = 'Error inicializando almacenamiento local: $e';
      AppLogger.error(
        '[OrderProvider] Error inicializando almacenamiento local',
        e,
      );
    }
  }

  /// Carga las órdenes locales del usuario actual
  Future<List<OrderModel>> loadLocalOrders() async {
    if (!_isLocalStorageInitialized) {
      await _initLocalStorage();
    }

    try {
      final userId = _productService.getCurrentUserId();
      if (userId != null) {
        final orders = _getSortedOrdersByUser(userId);
        _orders = orders;
        notifyListeners();

        // Asegurar que no hay duplicados al cargar órdenes
        await _deduplicationService.ensureNoDuplicates(userId);

        return orders;
      }
      return [];
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error('[OrderProvider] Error cargando órdenes locales', e);
      return [];
    }
  }

  /// Método helper para obtener órdenes ordenadas por fecha descendente
  List<OrderModel> _getSortedOrdersByUser(String userId) {
    final orders = _localStorage.getOrdersByUser(userId);
    // Ordenar por fecha de creación descendente (más recientes primero)
    orders.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return orders;
  }

  /// Crea una nueva cotización
  Future<bool> createQuote(List<SelectedProduct> products, double total) async {
    AppLogger.info(
      '[OrderProvider] Iniciando createQuote - Productos: ${products.length}, Total: $total',
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Esperar inicialización del almacenamiento local si no está listo
      if (!_isLocalStorageInitialized) {
        AppLogger.debug('[OrderProvider] Inicializando almacenamiento local');
        await _initLocalStorage();
      }

      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final order = OrderModel(
        userId: userId,
        statusIndex: OrderStatus.quote.index,
        products: products,
        total: total,
        createdAt: DateTime.now(),
      );

      await _localStorage.saveOrder(order);
      AppLogger.info('[OrderProvider] Orden guardada localmente exitosamente');

      _orders = _getSortedOrdersByUser(userId);
      notifyListeners();

      // Asegurar que no hay duplicados después de crear la orden
      await _deduplicationService.ensureNoDuplicates(userId);

      // Intentar guardar en Supabase (opcional)
      try {
        AppLogger.debug('[OrderProvider] Intentando guardar en Supabase');
        final supabaseOrder = await _productService.createQuote(
          products,
          total,
        );
        AppLogger.info('[OrderProvider] Orden guardada en Supabase');

        // Actualizar orden local con ID de Supabase y marcar como sincronizada
        final updatedOrder = order.copyWith(
          supabaseId: supabaseOrder.id,
          isSynced: true,
          syncVersion: 1,
          updatedAt: DateTime.now(),
        );
        await _localStorage.saveOrder(updatedOrder);
      } catch (e) {
        AppLogger.warning(
          '[OrderProvider] Error guardando en Supabase (continuando)',
          e,
        );
      }

      _isLoading = false;
      notifyListeners();
      AppLogger.info('[OrderProvider] createQuote completado exitosamente');
      return true;
    } catch (e) {
      AppLogger.error('[OrderProvider] Error en createQuote', e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Crea una nueva venta
  Future<bool> createSale(List<SelectedProduct> products, double total) async {
    AppLogger.info(
      '[OrderProvider] Iniciando createSale - Productos: ${products.length}, Total: $total',
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Esperar inicialización del almacenamiento local si no está listo
      if (!_isLocalStorageInitialized) {
        await _initLocalStorage();
      }

      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final order = OrderModel(
        userId: userId,
        statusIndex: OrderStatus.sale.index,
        products: products,
        total: total,
        createdAt: DateTime.now(),
      );

      await _localStorage.saveOrder(order);
      AppLogger.info('[OrderProvider] Orden guardada localmente exitosamente');

      _orders = _getSortedOrdersByUser(userId);
      notifyListeners();

      // Asegurar que no hay duplicados después de crear la orden
      await _deduplicationService.ensureNoDuplicates(userId);

      // Intentar guardar en Supabase
      try {
        AppLogger.debug('[OrderProvider] Intentando guardar en Supabase');
        final supabaseOrder = await _productService.createSale(products, total);
        AppLogger.info('[OrderProvider] Orden guardada en Supabase');

        // Actualizar orden local con ID de Supabase y marcar como sincronizada
        final updatedOrder = order.copyWith(
          supabaseId: supabaseOrder.id,
          isSynced: true,
          syncVersion: 1,
          updatedAt: DateTime.now(),
        );
        await _localStorage.saveOrder(updatedOrder);
      } catch (e) {
        AppLogger.warning(
          '[OrderProvider] Error guardando en Supabase (continuando)',
          e,
        );
      }

      _isLoading = false;
      notifyListeners();
      AppLogger.info('[OrderProvider] createSale completado exitosamente');
      return true;
    } catch (e) {
      AppLogger.error('[OrderProvider] Error en createSale', e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Crea una nueva venta con factura
  Future<bool> createSaleWithInvoice(
    List<SelectedProduct> products,
    double total,
  ) async {
    AppLogger.info(
      '[OrderProvider] Iniciando createSaleWithInvoice - Productos: ${products.length}, Total: $total',
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Esperar inicialización del almacenamiento local si no está listo
      if (!_isLocalStorageInitialized) {
        await _initLocalStorage();
      }

      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final order = OrderModel(
        userId: userId,
        statusIndex: OrderStatus.saleWithInvoice.index,
        products: products,
        total: total,
        createdAt: DateTime.now(),
      );

      await _localStorage.saveOrder(order);
      AppLogger.info('[OrderProvider] Orden guardada localmente exitosamente');

      _orders = _getSortedOrdersByUser(userId);
      notifyListeners();

      // Asegurar que no hay duplicados después de crear la orden
      await _deduplicationService.ensureNoDuplicates(userId);

      // Intentar guardar en Supabase
      try {
        AppLogger.debug('[OrderProvider] Intentando guardar en Supabase');
        final supabaseOrder = await _productService.createSaleWithInvoice(
          products,
          total,
        );
        AppLogger.info('[OrderProvider] Orden guardada en Supabase');

        // Actualizar orden local con ID de Supabase y marcar como sincronizada
        final updatedOrder = order.copyWith(
          supabaseId: supabaseOrder.id,
          isSynced: true,
          syncVersion: 1,
          updatedAt: DateTime.now(),
        );
        await _localStorage.saveOrder(updatedOrder);
      } catch (e) {
        AppLogger.warning(
          '[OrderProvider] Error guardando en Supabase (continuando)',
          e,
        );
      }

      _isLoading = false;
      notifyListeners();
      AppLogger.info(
        '[OrderProvider] createSaleWithInvoice completado exitosamente',
      );
      return true;
    } catch (e) {
      AppLogger.error('[OrderProvider] Error en createSaleWithInvoice', e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina una orden específica
  Future<bool> deleteOrder(OrderModel order) async {
    AppLogger.info('[OrderProvider] Iniciando deleteOrder - ID: ${order.id}');

    try {
      // Esperar inicialización del almacenamiento local si no está listo
      if (!_isLocalStorageInitialized) {
        await _initLocalStorage();
      }

      // Eliminar del almacenamiento local
      if (order.id == null || order.id!.isEmpty) {
        throw Exception('La orden no tiene un ID válido para eliminar');
      }
      await _localStorage.deleteOrder(order.id!);
      AppLogger.info('[OrderProvider] Orden eliminada localmente exitosamente');

      // Intentar eliminar de Supabase si tiene ID de Supabase
      if (order.supabaseId != null && order.supabaseId!.isNotEmpty) {
        try {
          AppLogger.debug('[OrderProvider] Intentando eliminar de Supabase');
          await _productService.deleteOrder(order.supabaseId!);
          AppLogger.info('[OrderProvider] Orden eliminada de Supabase');
        } catch (e) {
          AppLogger.warning(
            '[OrderProvider] Error eliminando de Supabase (continuando)',
            e,
          );
        }
      }

      // Actualizar la lista de órdenes
      final userId = _productService.getCurrentUserId();
      if (userId != null) {
        _orders = _getSortedOrdersByUser(userId);
      }
      notifyListeners();

      AppLogger.info('[OrderProvider] deleteOrder completado exitosamente');
      return true;
    } catch (e) {
      AppLogger.error('[OrderProvider] Error en deleteOrder', e);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Elimina todas las órdenes del usuario actual
  Future<bool> deleteAllOrders() async {
    AppLogger.info('[OrderProvider] Iniciando deleteAllOrders');

    try {
      // Esperar inicialización del almacenamiento local si no está listo
      if (!_isLocalStorageInitialized) {
        await _initLocalStorage();
      }

      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener todas las órdenes del usuario
      final allOrders = _localStorage.getOrdersByUser(userId);
      AppLogger.info('[OrderProvider] Órdenes a eliminar: ${allOrders.length}');

      // Eliminar todas las órdenes tanto localmente como de Supabase
      for (final order in allOrders) {
        try {
          // Determinar el ID de Supabase para eliminar
          String? supabaseIdToDelete;
          if (order.supabaseId != null && order.supabaseId!.isNotEmpty) {
            // Caso 1: Orden tiene supabaseId asignado (orden sincronizada)
            supabaseIdToDelete = order.supabaseId;
          } else if (order.isSynced &&
              order.id != null &&
              order.id!.isNotEmpty) {
            // Caso 2: Orden está marcada como sincronizada pero no tiene supabaseId
            // Usar order.id como fallback
            supabaseIdToDelete = order.id;
          }

          // Eliminar de Supabase si tenemos un ID válido
          if (supabaseIdToDelete != null) {
            AppLogger.debug(
              '[OrderProvider] Eliminando orden ${order.id} de Supabase',
            );
            await _productService.deleteOrder(supabaseIdToDelete);
            AppLogger.info(
              '[OrderProvider] Orden ${order.id} eliminada de Supabase',
            );
          } else {
            AppLogger.debug(
              '[OrderProvider] Orden ${order.id} no sincronizada, omitiendo eliminación de Supabase',
            );
          }

          // Eliminar del almacenamiento local
          if (order.id != null && order.id!.isNotEmpty) {
            await _localStorage.deleteOrder(order.id!);
            AppLogger.debug(
              '[OrderProvider] Orden ${order.id} eliminada localmente',
            );
          }
        } catch (e) {
          AppLogger.warning(
            '[OrderProvider] Error eliminando orden ${order.id}',
            e,
          );
          // Continuar con la siguiente orden
        }
      }

      // Actualizar la lista de órdenes (debería estar vacía)
      _orders = _getSortedOrdersByUser(userId);
      notifyListeners();

      AppLogger.info('[OrderProvider] deleteAllOrders completado exitosamente');
      return true;
    } catch (e) {
      AppLogger.error('[OrderProvider] Error en deleteAllOrders', e);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Realiza una sincronización completa de órdenes
  Future<void> performFullSync() async {
    try {
      await _syncService.performFullSync();
      // Recargar órdenes después de la sincronización
      await loadLocalOrders();
    } catch (e) {
      AppLogger.error('[OrderProvider] Error en sincronización completa', e);
      _errorMessage = 'Error en sincronización completa: $e';
      notifyListeners();
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
