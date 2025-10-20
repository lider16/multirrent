import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../controllers/product_provider.dart';
import '../models/product_model.dart';
import '../widgets/common/base_button.dart';
import '../widgets/common/base_text_field.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Cargar productos al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.loadProducts().then((_) {
        setState(() {
          _filteredProducts = productProvider.products;
        });
      });
    });

    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    setState(() {
      _filteredProducts = productProvider.products
          .where((product) => product.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _addProduct() async {
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

      // Recargar productos para actualizar la lista
      productProvider.loadProducts().then((_) {
        _filterProducts();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado exitosamente')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Error desconocido'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.inventoryScreenTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Row(
        children: [
          // Panel izquierdo: Formulario
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.addProductTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24),
                    BaseButton(
                      text: AppConstants.addProductButton,
                      onPressed: productProvider.isLoading ? null : _addProduct,
                      isLoading: productProvider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Panel derecho: Lista de productos
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppConstants.inventoryListTitle} (${_filteredProducts.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto por nombre...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? AppConstants.noProductsMessage
                                  : 'No se encontraron productos',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                color: Theme.of(context).cardColor,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${AppConstants.priceLabel} ${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            '${AppConstants.stockLabel} ${product.stock} ${AppConstants.unitsLabel}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
