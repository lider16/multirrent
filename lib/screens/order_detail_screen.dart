import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/order_model.dart';
import '../widgets/common/base_button.dart';
import 'print_preview_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de ${_getOrderTypeText(order.status)}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrintPreviewScreen(
                    selectedProducts: order.products,
                    totalAmount: order.total,
                    orderType: _getOrderTypeText(order.status),
                    orderId:
                        order.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                  ),
                ),
              );
            },
            tooltip: 'Imprimir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general de la orden
            Card(
              elevation: AppConstants.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.cardBorderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getOrderTypeIcon(order.status), size: 32),
                        const SizedBox(width: AppConstants.gridSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getOrderTypeText(order.status),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'ID: ${order.id ?? "Sin ID"}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.gridSpacing),
                    Text(
                      'Fecha: ${order.createdAt?.toString().split('.')[0] ?? "Sin fecha"}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppConstants.gridSpacing / 2),
                    Text(
                      'Usuario: ${order.userId}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.gridSpacing / 2),
                    Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.gridSpacing),

            // Lista de productos
            Text(
              'Productos (${order.products.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.gridSpacing),

            ...order.products.map(
              (product) => Card(
                elevation: AppConstants.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.inventory, size: 24),
                          const SizedBox(width: AppConstants.gridSpacing),
                          Expanded(
                            child: Text(
                              product.product.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.gridSpacing / 2),
                      Text(
                        'Cantidad: ${product.quantity} x \$${product.unitPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppConstants.gridSpacing / 2),
                      Text(
                        'Subtotal: \$${product.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (product.product.description.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.gridSpacing / 2),
                        Text(
                          'Descripción: ${product.product.description}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.gridSpacing),

            // Resumen total
            Card(
              elevation: AppConstants.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.cardBorderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.summarize, size: 24),
                        const SizedBox(width: AppConstants.gridSpacing),
                        Text(
                          'Resumen',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.gridSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.gridSpacing / 2),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.gridSpacing),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: BaseButton(
                    text: 'Imprimir',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrintPreviewScreen(
                            selectedProducts: order.products,
                            totalAmount: order.total,
                            orderType: _getOrderTypeText(order.status),
                            orderId:
                                order.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.gridSpacing),
                Expanded(
                  child: BaseButton(
                    text: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    buttonType: ButtonType.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
