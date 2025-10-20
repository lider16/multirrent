import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/order_model.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onPrint;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onPrint,
    required this.onDelete,
    this.onTap,
  });

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

  IconData _getOrderTypeIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.quote:
        return Icons.description;
      case OrderStatus.sale:
        return Icons.shopping_cart;
      case OrderStatus.saleWithInvoice:
        return Icons.receipt;
    }
  }

  Widget _buildSyncIndicator() {
    if (order.isSynced) {
      return Icon(Icons.cloud_done, size: 16, color: Colors.green);
    } else {
      return Icon(Icons.cloud_off, size: 16, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: ListTile(
        leading: Icon(
          _getOrderTypeIcon(order.status),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getOrderTypeText(order.status),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _buildSyncIndicator(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: ${order.createdAt?.toString().split('.')[0] ?? "Sin fecha"}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${order.products.length} producto${order.products.length != 1 ? 's' : ''} • \$${order.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'print':
                onPrint();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print, size: 20),
                  SizedBox(width: 8),
                  Text('Imprimir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
