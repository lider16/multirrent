import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/selected_product.dart';
import 'base_button.dart';
import 'product_cart_item.dart';

class SelectedProductsPanel extends StatelessWidget {
  final List<SelectedProduct> selectedProducts;
  final Function(int, double) onUpdatePrice;
  final Function(int, int) onUpdateQuantity;
  final Function(int) onRemove;
  final double totalAmount;
  final VoidCallback onQuote;
  final VoidCallback onSale;
  final VoidCallback onSaleWithInvoice;
  final bool isSaving;

  const SelectedProductsPanel({
    super.key,
    required this.selectedProducts,
    required this.onUpdatePrice,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.totalAmount,
    required this.onQuote,
    required this.onSale,
    required this.onSaleWithInvoice,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos Seleccionados (${selectedProducts.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Lista de productos seleccionados
          Expanded(
            child: selectedProducts.isEmpty
                ? Center(
                    child: Text(
                      'Seleccione productos del panel derecho',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedProducts.length,
                    itemBuilder: (context, index) {
                      final selectedProduct = selectedProducts[index];
                      return ProductCartItem(
                        selectedProduct: selectedProduct,
                        index: index,
                        onUpdatePrice: onUpdatePrice,
                        onUpdateQuantity: onUpdateQuantity,
                        onRemove: onRemove,
                      );
                    },
                  ),
          ),
          // Total general
          if (selectedProducts.isNotEmpty) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total General:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${AppConstants.currencySymbol}${totalAmount.toStringAsFixed(2).replaceAll('.00', '')}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: BaseButton(
                    text: isSaving ? 'Guardando...' : 'Cotización',
                    onPressed: isSaving ? null : onQuote,
                    height: AppConstants.buttonHeightLarge,
                    fontSize: AppConstants.buttonFontSizeLarge,
                    buttonType: ButtonType.strongPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BaseButton(
                    text: isSaving ? 'Guardando...' : 'Venta',
                    onPressed: isSaving ? null : onSale,
                    height: AppConstants.buttonHeightLarge,
                    fontSize: AppConstants.buttonFontSizeLarge,
                    buttonType: ButtonType.strongPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BaseButton(
                    text: isSaving ? 'Guardando...' : 'Venta Factura',
                    onPressed: isSaving ? null : onSaleWithInvoice,
                    height: AppConstants.buttonHeightLarge,
                    fontSize: AppConstants.buttonFontSizeLarge,
                    buttonType: ButtonType.strongPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
