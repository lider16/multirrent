import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../controllers/order_provider.dart';
import '../models/order_model.dart';
import '../widgets/common/base_button.dart';
import '../widgets/common/order_history_card.dart';
import 'print_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _hasLoadedOrders = false;

  @override
  void initState() {
    super.initState();
    _ensureOrdersLoaded();
  }

  Future<void> _ensureOrdersLoaded() async {
    if (_hasLoadedOrders) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    if (provider.orders.isEmpty) {
      await provider.loadLocalOrders();
      _hasLoadedOrders = true;
    }
  }

  String _getOrderTypeText(OrderStatus status) {
    switch (status) {
      case OrderStatus.quote:
        return 'Cotización';
      case OrderStatus.sale:
        return 'Venta';
      case OrderStatus.saleWithInvoice:
        return 'Venta con Factura';
    }
  }

  Future<void> _handlePrint(BuildContext context, OrderModel order) async {
    print('🖨️ [HistoryScreen] Imprimiendo orden: ${order.id}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintPreviewScreen(
          selectedProducts: order.products,
          totalAmount: order.total,
          orderType: _getOrderTypeText(order.status),
          orderId: order.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, OrderModel order) async {
    print('🗑️ [HistoryScreen] Eliminando orden: ${order.id}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar esta ${_getOrderTypeText(order.status).toLowerCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final orderProvider = Provider.of<OrderProvider>(
          context,
          listen: false,
        );
        final success = await orderProvider.deleteOrder(order);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_getOrderTypeText(order.status)} eliminada exitosamente',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRefresh(BuildContext context) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Ejecutar sincronización completa
      await orderProvider.performFullSync();

      if (context.mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial actualizado exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAllOrders(BuildContext context) async {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final orders = provider.orders;

    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay órdenes para eliminar')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todo el historial'),
        content: Text(
          '¿Estás seguro de que quieres eliminar todas las órdenes (${orders.length} en total)?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await provider.deleteAllOrders();

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo el historial ha sido eliminado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar historial: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final orders = provider.orders;

        // Calcular estadísticas
        final quotesCount = orders
            .where((order) => order.status == OrderStatus.quote)
            .length;
        final salesCount = orders
            .where((order) => order.status == OrderStatus.sale)
            .length;
        final salesWithInvoiceCount = orders
            .where((order) => order.status == OrderStatus.saleWithInvoice)
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Historial de Órdenes'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Eliminar todo el historial',
                onPressed: () => _handleDeleteAllOrders(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Órdenes Guardadas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppConstants.gridSpacing),
                // Estadísticas
                Card(
                  elevation: AppConstants.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.cardBorderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.cardPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Cotizaciones',
                          quotesCount,
                          Icons.description,
                        ),
                        _buildStatItem(
                          context,
                          'Ventas',
                          salesCount,
                          Icons.shopping_cart,
                        ),
                        _buildStatItem(
                          context,
                          'Con Factura',
                          salesWithInvoiceCount,
                          Icons.receipt,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.gridSpacing),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (orders.isEmpty)
                  const Center(child: Text('No hay órdenes guardadas'))
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _handleRefresh(context),
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: OrderHistoryCard(
                              order: order,
                              onPrint: () => _handlePrint(context, order),
                              onDelete: () => _handleDelete(context, order),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: AppConstants.gridSpacing),
                BaseButton(
                  text: provider.isLoading ? 'Actualizando...' : 'Actualizar',
                  onPressed: provider.isLoading
                      ? null
                      : () => _handleRefresh(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
