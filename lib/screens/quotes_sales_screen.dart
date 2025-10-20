import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore_for_file: use_build_context_synchronously
import '../constants/app_constants.dart';
import '../controllers/product_provider.dart';
import '../controllers/order_provider.dart';
import '../models/product_model.dart';
import '../models/selected_product.dart';
import '../widgets/common/available_products_panel.dart';
import '../widgets/common/base_button.dart';
import '../widgets/common/base_text_field.dart';
import '../widgets/common/selected_products_panel.dart';
import 'print_preview_screen.dart';

class QuotesSalesScreen extends StatefulWidget {
  const QuotesSalesScreen({super.key});

  @override
  State<QuotesSalesScreen> createState() => _QuotesSalesScreenState();
}

class _QuotesSalesScreenState extends State<QuotesSalesScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Estado para productos seleccionados
  List<SelectedProduct> selectedProducts = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar productos al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Producto'),
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
              child: const Text('Cancelar'),
            ),
            BaseButton(
              text: AppConstants.addProductButton,
              onPressed: () => _addProduct(context),
              width: 120,
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProduct(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    final success = await productProvider.addProduct(
      name: name,
      description: description,
      price: price,
      stock: stock,
    );

    if (success && mounted) {
      // Limpiar formulario
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();

      Navigator.of(dialogContext).pop(); // Cerrar dialog

      // Recargar productos para actualización inmediata
      await productProvider.loadProducts();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto agregado exitosamente')),
          );
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Error desconocido'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Métodos para manejar productos seleccionados
  void addProductToCart(Product product) {
    setState(() {
      // Verificar si ya está en el carrito
      final existingIndex = selectedProducts.indexWhere(
        (selected) => selected.product.id == product.id,
      );
      if (existingIndex >= 0) {
        // Incrementar cantidad si ya existe
        selectedProducts[existingIndex] = selectedProducts[existingIndex]
            .copyWith(quantity: selectedProducts[existingIndex].quantity + 1);
      } else {
        // Agregar nuevo
        selectedProducts.add(
          SelectedProduct(
            product: product,
            unitPrice: product.price,
            quantity: 1,
          ),
        );
      }
    });
  }

  void updateProductPrice(int index, double newPrice) {
    setState(() {
      selectedProducts[index] = selectedProducts[index].copyWith(
        unitPrice: newPrice,
      );
    });
  }

  void updateProductQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) return;
    setState(() {
      selectedProducts[index] = selectedProducts[index].copyWith(
        quantity: newQuantity,
      );
    });
  }

  void removeProductFromCart(int index) {
    setState(() {
      selectedProducts.removeAt(index);
    });
  }

  double get totalAmount {
    return selectedProducts.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> _handleQuote() async {
    print('🔍 [QuotesSalesScreen] _handleQuote presionado');
    print(
      '📦 [QuotesSalesScreen] selectedProducts: ${selectedProducts.length}',
    );
    print('💰 [QuotesSalesScreen] totalAmount: $totalAmount');

    if (selectedProducts.isEmpty) {
      print('⚠️ [QuotesSalesScreen] No hay productos seleccionados');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agregue productos para crear una cotización'),
        ),
      );
      return;
    }

    print('⏳ [QuotesSalesScreen] Iniciando guardado...');
    setState(() => _isSaving = true);
    try {
      print('🔗 [QuotesSalesScreen] Obteniendo ProductProvider...');
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      print('📤 [QuotesSalesScreen] Llamando createQuote...');
      final success = await orderProvider.createQuote(
        selectedProducts,
        totalAmount,
      );

      print('📥 [QuotesSalesScreen] createQuote retornó: $success');
      if (success && mounted) {
        print('✅ [QuotesSalesScreen] Cotización guardada exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización guardada localmente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrintPreviewScreen(
              selectedProducts: selectedProducts,
              totalAmount: totalAmount,
              orderType: 'Cotización',
              orderId: DateTime.now().millisecondsSinceEpoch
                  .toString(), // ID temporal
            ),
          ),
        );
      } else {
        print('❌ [QuotesSalesScreen] createQuote falló');
      }
    } catch (e) {
      print('💥 [QuotesSalesScreen] Error en _handleQuote: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cotización: $e')),
        );
      }
    } finally {
      if (mounted) {
        print('🔄 [QuotesSalesScreen] Finalizando _handleQuote');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleSale() async {
    print('🔍 [QuotesSalesScreen] _handleSale presionado');
    print(
      '📦 [QuotesSalesScreen] selectedProducts: ${selectedProducts.length}',
    );
    print('💰 [QuotesSalesScreen] totalAmount: $totalAmount');

    if (selectedProducts.isEmpty) {
      print('⚠️ [QuotesSalesScreen] No hay productos seleccionados');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agregue productos para registrar una venta'),
        ),
      );
      return;
    }

    print('⏳ [QuotesSalesScreen] Iniciando guardado de venta...');
    setState(() => _isSaving = true);
    try {
      print('🔗 [QuotesSalesScreen] Obteniendo ProductProvider...');
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      print('📤 [QuotesSalesScreen] Llamando createSale...');
      final success = await orderProvider.createSale(
        selectedProducts,
        totalAmount,
      );

      print('📥 [QuotesSalesScreen] createSale retornó: $success');
      if (success && mounted) {
        print('✅ [QuotesSalesScreen] Venta guardada exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta guardada localmente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrintPreviewScreen(
              selectedProducts: selectedProducts,
              totalAmount: totalAmount,
              orderType: 'Venta',
              orderId: DateTime.now().millisecondsSinceEpoch
                  .toString(), // ID temporal
            ),
          ),
        );
      } else {
        print('❌ [QuotesSalesScreen] createSale falló');
      }
    } catch (e) {
      print('💥 [QuotesSalesScreen] Error en _handleSale: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar venta: $e')));
      }
    } finally {
      if (mounted) {
        print('🔄 [QuotesSalesScreen] Finalizando _handleSale');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleSaleWithInvoice() async {
    print('🔍 [QuotesSalesScreen] _handleSaleWithInvoice presionado');
    print(
      '📦 [QuotesSalesScreen] selectedProducts: ${selectedProducts.length}',
    );
    print('💰 [QuotesSalesScreen] totalAmount: $totalAmount');

    if (selectedProducts.isEmpty) {
      print('⚠️ [QuotesSalesScreen] No hay productos seleccionados');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agregue productos para registrar una venta con factura',
          ),
        ),
      );
      return;
    }

    print('⏳ [QuotesSalesScreen] Iniciando guardado de venta con factura...');
    setState(() => _isSaving = true);
    try {
      print('🔗 [QuotesSalesScreen] Obteniendo ProductProvider...');
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      print('📤 [QuotesSalesScreen] Llamando createSaleWithInvoice...');
      final success = await orderProvider.createSaleWithInvoice(
        selectedProducts,
        totalAmount,
      );

      print('📥 [QuotesSalesScreen] createSaleWithInvoice retornó: $success');
      if (success && mounted) {
        print('✅ [QuotesSalesScreen] Venta con factura guardada exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta con factura guardada localmente'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrintPreviewScreen(
              selectedProducts: selectedProducts,
              totalAmount: totalAmount,
              orderType: 'Factura Electrónica',
              orderId: DateTime.now().millisecondsSinceEpoch
                  .toString(), // ID temporal
            ),
          ),
        );
      } else {
        print('❌ [QuotesSalesScreen] createSaleWithInvoice falló');
      }
    } catch (e) {
      print('💥 [QuotesSalesScreen] Error en _handleSaleWithInvoice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar venta con factura: $e')),
        );
      }
    } finally {
      if (mounted) {
        print('🔄 [QuotesSalesScreen] Finalizando _handleSaleWithInvoice');
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones y Ventas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Row(
        children: [
          // Panel izquierdo: Carrito de productos seleccionados
          Expanded(
            flex: 2,
            child: SelectedProductsPanel(
              selectedProducts: selectedProducts,
              onUpdatePrice: updateProductPrice,
              onUpdateQuantity: updateProductQuantity,
              onRemove: removeProductFromCart,
              totalAmount: totalAmount,
              onQuote: _handleQuote,
              onSale: _handleSale,
              onSaleWithInvoice: _handleSaleWithInvoice,
              isSaving: _isSaving,
            ),
          ),
          // Panel derecho: Lista de productos con búsqueda
          Expanded(
            flex: 1,
            child: AvailableProductsPanel(
              searchController: _searchController,
              onShowAddProductDialog: _showAddProductDialog,
              onAddProductToCart: addProductToCart,
            ),
          ),
        ],
      ),
    );
  }
}
