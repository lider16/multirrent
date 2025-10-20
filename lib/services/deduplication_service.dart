import '../models/order_model.dart';
import '../services/local_storage_service.dart';
import 'app_logger.dart';

/// Servicio dedicado para manejar la deduplicación de órdenes
/// Proporciona funcionalidades para identificar y eliminar órdenes duplicadas
/// basándose en criterios de similitud y selección de la mejor versión
class DeduplicationService {
  final LocalStorageService _localStorage;

  /// Constructor que requiere el servicio de almacenamiento local
  DeduplicationService(this._localStorage);

  /// Asegura que no hay órdenes duplicadas para un usuario específico
  /// Elimina duplicados y mantiene solo la mejor versión de cada orden
  Future<void> ensureNoDuplicates(String userId) async {
    try {
      AppLogger.info(
        '[Deduplication] Iniciando verificación de duplicados para usuario: $userId',
      );

      // Obtener todas las órdenes actuales del usuario
      final currentOrders = _localStorage.getOrdersByUser(userId);
      if (currentOrders.isEmpty) {
        AppLogger.debug(
          '[Deduplication] No hay órdenes para verificar duplicados',
        );
        return;
      }

      // Aplicar deduplicación
      final deduplicatedOrders = deduplicateOrders(currentOrders);

      // Si se encontraron duplicados, actualizar el almacenamiento
      if (deduplicatedOrders.length < currentOrders.length) {
        final duplicatesRemoved =
            currentOrders.length - deduplicatedOrders.length;
        AppLogger.warning(
          '[Deduplication] Eliminando $duplicatesRemoved órdenes duplicadas',
        );

        // Limpiar todas las órdenes del usuario
        for (final order in currentOrders) {
          if (order.id != null) {
            await _localStorage.deleteOrder(order.id!);
          }
        }

        // Guardar las órdenes deduplicadas
        for (final order in deduplicatedOrders) {
          await _localStorage.saveOrder(order);
        }

        AppLogger.info('[Deduplication] Deduplicación completada exitosamente');
      } else {
        AppLogger.debug('[Deduplication] No se encontraron órdenes duplicadas');
      }
    } catch (e) {
      AppLogger.error('[Deduplication] Error en ensureNoDuplicates', e);
      // No fallar la operación principal por errores de deduplicación
    }
  }

  /// Deduplica una lista de órdenes basado en criterios de similitud
  /// Retorna una lista con solo una versión de cada orden duplicada
  List<OrderModel> deduplicateOrders(List<OrderModel> orders) {
    AppLogger.info(
      '[Deduplication] Iniciando deduplicación de ${orders.length} órdenes',
    );

    final Map<String, List<OrderModel>> orderGroups = {};
    final List<OrderModel> deduplicatedOrders = [];

    // Crear huella digital para cada orden y agrupar
    for (final order in orders) {
      final fingerprint = _createOrderFingerprint(order);
      if (!orderGroups.containsKey(fingerprint)) {
        orderGroups[fingerprint] = [];
      }
      orderGroups[fingerprint]!.add(order);
    }

    // Procesar cada grupo
    for (final fingerprint in orderGroups.keys) {
      final group = orderGroups[fingerprint]!;

      if (group.length == 1) {
        // Solo una orden en el grupo, mantenerla
        deduplicatedOrders.add(group[0]);
      } else {
        // Múltiples órdenes, seleccionar la mejor
        AppLogger.warning(
          '[Deduplication] Encontrado grupo duplicado (${group.length} órdenes) con huella: $fingerprint',
        );
        final bestOrder = _selectBestOrder(group);
        deduplicatedOrders.add(bestOrder);
        AppLogger.info(
          '[Deduplication] Manteniendo orden: ${bestOrder.id} (${bestOrder.supabaseId})',
        );
      }
    }

    AppLogger.info(
      '[Deduplication] Deduplicación completada: ${orders.length} → ${deduplicatedOrders.length} órdenes',
    );
    return deduplicatedOrders;
  }

  /// Crea una huella digital única para identificar órdenes duplicadas
  /// La huella incluye userId, status, fecha de creación, total y detalles de productos
  String _createOrderFingerprint(OrderModel order) {
    // Huella más precisa: userId + status + createdAt(segundos) + total + productos(detallados con cantidades)
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

    // Crear firma detallada de productos incluyendo nombres completos y cantidades
    final productsSignature = order.products
        .map(
          (product) =>
              '${product.product.name}:${product.quantity}:${product.product.price}',
        )
        .join('|');

    return '${order.userId}_${order.status.index}_${createdAtSeconds?.toIso8601String() ?? 'null'}_$order.total_$productsSignature';
  }

  /// Selecciona la mejor orden de un grupo de órdenes duplicadas
  /// Criterios de selección: supabaseId > updatedAt > syncVersion
  OrderModel _selectBestOrder(List<OrderModel> orders) {
    // Prioridad: 1. Tiene supabaseId, 2. Más reciente updatedAt, 3. Mayor syncVersion
    return orders.reduce((best, current) {
      // Si una tiene supabaseId y la otra no, preferir la que tiene
      if (best.supabaseId != null && current.supabaseId == null) return best;
      if (best.supabaseId == null && current.supabaseId != null) return current;

      // Si ambas tienen supabaseId o ninguna, comparar updatedAt
      if (best.updatedAt != null && current.updatedAt != null) {
        return best.updatedAt!.isAfter(current.updatedAt!) ? best : current;
      }

      // Si no hay updatedAt, comparar syncVersion
      if (best.syncVersion != current.syncVersion) {
        return best.syncVersion > current.syncVersion ? best : current;
      }

      // Como último recurso, mantener la primera
      return best;
    });
  }
}
