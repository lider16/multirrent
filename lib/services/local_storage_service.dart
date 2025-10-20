import 'package:hive/hive.dart';
import '../models/order_model.dart';

class LocalStorageService {
  static const String ordersBoxName = 'orders';

  late Box<OrderModel> _ordersBox;

  Future<void> init() async {
    _ordersBox = await Hive.openBox<OrderModel>(ordersBoxName);
  }

  // Guardar una orden localmente
  Future<void> saveOrder(OrderModel order) async {
    // Generar ID si no tiene
    final orderToSave = order.id == null || order.id!.isEmpty
        ? order.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : order;

    await _ordersBox.put(orderToSave.id, orderToSave);
  }

  // Obtener todas las órdenes
  List<OrderModel> getAllOrders() {
    return _ordersBox.values.toList();
  }

  // Obtener órdenes por usuario
  List<OrderModel> getOrdersByUser(String userId) {
    return _ordersBox.values.where((order) => order.userId == userId).toList();
  }

  // Eliminar una orden
  Future<void> deleteOrder(String orderId) async {
    await _ordersBox.delete(orderId);
  }

  // Limpiar todas las órdenes
  Future<void> clearAllOrders() async {
    await _ordersBox.clear();
  }

  // Cerrar la caja
  Future<void> close() async {
    await _ordersBox.close();
  }
}
