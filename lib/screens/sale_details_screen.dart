import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/selected_product.dart';
import '../widgets/common/base_button.dart';
import '../widgets/common/base_card.dart';
import 'print_preview_screen.dart';

class SaleDetailsScreen extends StatelessWidget {
  final List<SelectedProduct> selectedProducts;
  final double totalAmount;
  final String? orderId;

  const SaleDetailsScreen({
    super.key,
    required this.selectedProducts,
    required this.totalAmount,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Venta'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Vendidos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.gridSpacing),
            Expanded(
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final item = selectedProducts[index];
                  return BaseCard(
                    title: item.product.name,
                    description:
                        'Cantidad: ${item.quantity} - Precio: \$${item.unitPrice.toStringAsFixed(2)}',
                    icon: Icons.shopping_cart,
                    onTap: () {}, // No action needed
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.gridSpacing),
            Text(
              'Total: \$${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.gridSpacing),
            BaseButton(
              text: 'Imprimir Venta',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrintPreviewScreen(
                      selectedProducts: selectedProducts,
                      totalAmount: totalAmount,
                      orderType: 'Venta',
                      orderId: orderId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
