import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'base_button.dart';
import 'base_text_field.dart';

/// Diálogo reutilizable para agregar o editar productos
class ProductDialog extends StatefulWidget {
  final Product? product; // null para agregar, existente para editar
  final Function(Product) onSave;

  const ProductDialog({super.key, this.product, required this.onSave});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final product = widget.product != null
        ? widget.product!.copyWith(
            name: name,
            description: description,
            price: price,
            stock: stock,
          )
        : Product.create(
            userId: '', // Se asignará en el provider
            name: name,
            description: description,
            price: price,
            stock: stock,
          );

    widget.onSave(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Editar Producto' : AppConstants.addProductTitle,
        style: AppTextStyles.titleLarge,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseTextField(
                controller: _nameController,
                hintText: AppConstants.productNameHint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BaseTextField(
                controller: _descriptionController,
                hintText: AppConstants.productDescriptionHint,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BaseTextField(
                controller: _priceController,
                hintText: AppConstants.productPriceHint,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Ingresa un precio válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BaseTextField(
                controller: _stockController,
                hintText: AppConstants.productStockHint,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el stock';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Ingresa un stock válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
        BaseButton(
          text: isEditing ? 'Actualizar' : AppConstants.addProductButton,
          onPressed: _saveProduct,
          width: 120,
        ),
      ],
    );
  }
}
