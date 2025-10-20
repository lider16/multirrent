import '../models/order_model.dart';
import '../services/product_service.dart';
import '../services/local_storage_service.dart';
import '../services/deduplication_service.dart';
import 'app_logger.dart';

/// Servicio dedicado para manejar la sincronización de órdenes entre
/// almacenamiento local y Supabase
class SyncService {
  final ProductService _productService;
  final LocalStorageService _localStorage;
  final DeduplicationService _deduplicationService;

  /// Constructor que requiere los servicios necesarios
  SyncService(
    this._productService,
    this._localStorage,
    this._deduplicationService,
  );

  /// Sincroniza órdenes locales no sincronizadas hacia Supabase
  Future<void> syncLocalOrdersToSupabase() async {
    AppLogger.info('[Sync] Iniciando sincronización local → Supabase');

    try {
      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        AppLogger.warning(
          '[Sync] Usuario no autenticado, saltando sincronización',
        );
        return;
      }

      final localOrders = _localStorage.getOrdersByUser(userId);
      final unsyncedOrders = localOrders
          .where((order) => !order.isSynced)
          .toList();

      AppLogger.info(
        '[Sync] Órdenes locales: ${localOrders.length}, no sincronizadas: ${unsyncedOrders.length}',
      );

      for (final order in unsyncedOrders) {
        try {
          AppLogger.debug('[Sync] Subiendo orden ${order.id}');

          // Crear en Supabase
          final supabaseOrder = await _createOrderInSupabase(order);

          // Actualizar orden local con ID de Supabase y marcar como sincronizada
          final updatedOrder = order.copyWith(
            supabaseId: supabaseOrder.id,
            isSynced: true,
            syncVersion: order.syncVersion + 1,
            updatedAt: DateTime.now(),
          );

          await _localStorage.saveOrder(updatedOrder);
          AppLogger.info('[Sync] Orden ${order.id} sincronizada exitosamente');
        } catch (e) {
          AppLogger.error('[Sync] Error sincronizando orden ${order.id}', e);
          // Continuar con la siguiente orden
        }
      }

      AppLogger.info('[Sync] Sincronización local → Supabase completada');
    } catch (e) {
      AppLogger.error('[Sync] Error en sincronización local → Supabase', e);
      throw Exception('Error en sincronización: $e');
    }
  }

  /// Descarga órdenes de Supabase y las fusiona con las locales
  Future<void> syncSupabaseOrdersToLocal() async {
    AppLogger.info('[Sync] Iniciando sincronización Supabase → local');

    try {
      final userId = _productService.getCurrentUserId();
      if (userId == null) {
        AppLogger.warning(
          '[Sync] Usuario no autenticado, saltando sincronización',
        );
        return;
      }

      // Obtener órdenes de Supabase
      final supabaseOrders = await _productService.getOrderHistory();
      AppLogger.info(
        '[Sync] Órdenes descargadas de Supabase: ${supabaseOrders.length}',
      );

      // Obtener órdenes locales
      final localOrders = _localStorage.getOrdersByUser(userId);
      AppLogger.debug('[Sync] Órdenes locales: ${localOrders.length}');

      // Fusionar órdenes
      final mergedOrders = await _mergeOrders(localOrders, supabaseOrders);

      // Aplicar deduplicación para eliminar órdenes duplicadas
      final deduplicatedOrders = _deduplicationService.deduplicateOrders(
        mergedOrders,
      );

      // Guardar órdenes deduplicadas
      for (final order in deduplicatedOrders) {
        await _localStorage.saveOrder(order);
      }

      AppLogger.info('[Sync] Sincronización Supabase → local completada');
    } catch (e) {
      AppLogger.error('[Sync] Error en sincronización Supabase → local', e);
      throw Exception('Error descargando datos: $e');
    }
  }

  /// Realiza una sincronización completa bidireccional
  Future<void> performFullSync() async {
    AppLogger.info('[Sync] Iniciando sincronización completa');

    try {
      // Primero descargar de Supabase
      await syncSupabaseOrdersToLocal();

      // Luego subir cambios locales
      await syncLocalOrdersToSupabase();

      AppLogger.info('[Sync] Sincronización completa exitosa');
    } catch (e) {
      AppLogger.error('[Sync] Error en sincronización completa', e);
      throw Exception('Error en sincronización completa: $e');
    }
  }

  /// Marca una orden específica como sincronizada
  Future<void> markOrderAsSynced(String orderId) async {
    try {
      final userId = _productService.getCurrentUserId();
      if (userId == null) return;

      final orders = _localStorage.getOrdersByUser(userId);
      final order = orders.firstWhere((o) => o.id == orderId);

      final updatedOrder = order.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );

      await _localStorage.saveOrder(updatedOrder);
      AppLogger.debug('[Sync] Orden $orderId marcada como sincronizada');
    } catch (e) {
      AppLogger.error(
        '[Sync] Error marcando orden como sincronizada: $orderId',
        e,
      );
      throw e;
    }
  }

  /// Crea una orden en Supabase usando el servicio apropiado según el tipo
  Future<OrderModel> _createOrderInSupabase(OrderModel order) async {
    switch (order.status) {
      case OrderStatus.quote:
        return await _productService.createQuote(order.products, order.total);
      case OrderStatus.sale:
        return await _productService.createSale(order.products, order.total);
      case OrderStatus.saleWithInvoice:
        return await _productService.createSaleWithInvoice(
          order.products,
          order.total,
        );
    }
  }

  /// Fusiona listas de órdenes locales y remotas, resolviendo conflictos
  Future<List<OrderModel>> _mergeOrders(
    List<OrderModel> localOrders,
    List<OrderModel> supabaseOrders,
  ) async {
    final mergedOrders = <OrderModel>[];
    final processedIds = <String>{};

    // Procesar órdenes locales primero
    for (final localOrder in localOrders) {
      // Buscar orden correspondiente en Supabase usando comparación inteligente
      final remoteOrder = _findMatchingOrder(localOrder, supabaseOrders);

      if (remoteOrder != null) {
        // Existe en ambos, resolver conflicto
        final mergedOrder = _resolveConflict(localOrder, remoteOrder);
        mergedOrders.add(mergedOrder);
        if (localOrder.id != null) processedIds.add(localOrder.id!);
        if (remoteOrder.id != null) processedIds.add(remoteOrder.id!);
      } else {
        // Solo existe localmente
        mergedOrders.add(localOrder);
        if (localOrder.id != null) processedIds.add(localOrder.id!);
      }
    }

    // Agregar órdenes que solo existen en remoto
    for (final remoteOrder in supabaseOrders) {
      if (remoteOrder.id != null && !processedIds.contains(remoteOrder.id!)) {
        mergedOrders.add(remoteOrder.copyWith(isSynced: true));
      }
    }

    return mergedOrders;
  }

  /// Busca una orden correspondiente usando comparación inteligente
  OrderModel? _findMatchingOrder(
    OrderModel localOrder,
    List<OrderModel> supabaseOrders,
  ) {
    // Primero intentar coincidencia exacta por supabaseId
    if (localOrder.supabaseId != null) {
      final exactMatch = supabaseOrders.firstWhere(
        (remote) => remote.id == localOrder.supabaseId,
        orElse: () =>
            OrderModel(userId: '', statusIndex: 0, products: [], total: 0),
      );
      if (exactMatch.id != null) return exactMatch;
    }

    // Si no hay coincidencia exacta, buscar por similitud (misma huella digital)
    final localFingerprint = _createOrderFingerprint(localOrder);
    for (final remoteOrder in supabaseOrders) {
      final remoteFingerprint = _createOrderFingerprint(remoteOrder);
      if (localFingerprint == remoteFingerprint) {
        return remoteOrder;
      }
    }

    // Si no se encuentra coincidencia, devolver null
    return null;
  }

  /// Resuelve conflictos entre versiones local y remota de una orden
  OrderModel _resolveConflict(OrderModel local, OrderModel remote) {
    // Estrategia: la versión más reciente gana
    if (local.updatedAt != null && remote.updatedAt != null) {
      return local.updatedAt!.isAfter(remote.updatedAt!) ? local : remote;
    }

    // Si no hay timestamps, usar versión de sync
    if (local.syncVersion > remote.syncVersion) {
      return local;
    } else {
      return remote;
    }
  }

  /// Crea una huella digital para identificar órdenes (método auxiliar)
  String _createOrderFingerprint(OrderModel order) {
    final createdAtSeconds = order.createdAt != null
        ? DateTime(
            order.createdAt!.year,
            order.createdAt!.month,
            order.createdAt!.day,
            order.createdAt!.hour,
            order.createdAt!.minute,
            order.createdAt!.second,
          )
        : null;

    final productsSignature = order.products
        .map(
          (product) =>
              '${product.product.name}:${product.quantity}:${product.product.price}',
        )
        .join('|');

    return '${order.userId}_${order.status.index}_${createdAtSeconds?.toIso8601String() ?? 'null'}_$order.total_$productsSignature';
  }
}
