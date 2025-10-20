import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/selected_product.dart';
import 'base_text_field.dart';

class ProductCartItem extends StatefulWidget {
  final SelectedProduct selectedProduct;
  final int index;
  final Function(int, double) onUpdatePrice;
  final Function(int, int) onUpdateQuantity;
  final Function(int) onRemove;

  const ProductCartItem({
    super.key,
    required this.selectedProduct,
    required this.index,
    required this.onUpdatePrice,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  State<ProductCartItem> createState() => _ProductCartItemState();
}

class _ProductCartItemState extends State<ProductCartItem> {
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.selectedProduct.unitPrice
          .toStringAsFixed(2)
          .replaceAll('.00', ''),
    );
    _quantityController = TextEditingController(
      text: widget.selectedProduct.quantity.toString(),
    );

    _priceController.addListener(_onPriceChanged);
    _quantityController.addListener(_onQuantityChanged);
  }

  @override
  void didUpdateWidget(ProductCartItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar texto solo si cambió el valor del producto
    if (oldWidget.selectedProduct.unitPrice !=
        widget.selectedProduct.unitPrice) {
      final newText = widget.selectedProduct.unitPrice
          .toStringAsFixed(2)
          .replaceAll('.00', '');
      if (_priceController.text != newText) {
        _priceController.removeListener(_onPriceChanged);
        _priceController.text = newText;
        _priceController.addListener(_onPriceChanged);
      }
    }
    if (oldWidget.selectedProduct.quantity != widget.selectedProduct.quantity) {
      final newText = widget.selectedProduct.quantity.toString();
      if (_quantityController.text != newText) {
        _quantityController.removeListener(_onQuantityChanged);
        _quantityController.text = newText;
        _quantityController.addListener(_onQuantityChanged);
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    final text = _priceController.text.trim();
    if (text.isEmpty) return; // Permitir edición cuando está vacío
    final price = double.tryParse(text);
    if (price != null && price >= 0) {
      widget.onUpdatePrice(widget.index, price);
    }
  }

  void _onQuantityChanged() {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    if (qty > 0) {
      widget.onUpdateQuantity(widget.index, qty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedProduct.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onRemove(widget.index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Campos editables
            Row(
              children: [
                Expanded(
                  child: BaseTextField(
                    controller: _priceController,
                    hintText: 'Precio',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      '${AppConstants.currencySymbol}${widget.selectedProduct.priceWithoutIva.toStringAsFixed(2).replaceAll('.00', '')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BaseTextField(
                    controller: _quantityController,
                    hintText: 'Cant.',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${AppConstants.currencySymbol}${widget.selectedProduct.total.toStringAsFixed(2).replaceAll('.00', '')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
