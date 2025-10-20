import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/product_provider.dart';
import '../../models/product_model.dart';
import 'base_button.dart';
import 'base_text_field.dart';

class AvailableProductsPanel extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onShowAddProductDialog;
  final Function(Product) onAddProductToCart;

  const AvailableProductsPanel({
    super.key,
    required this.searchController,
    required this.onShowAddProductDialog,
    required this.onAddProductToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final searchText = searchController.text.toLowerCase();
          final filteredProducts = productProvider.products
              .where(
                (product) => product.name.toLowerCase().contains(searchText),
              )
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Botón agregar + Buscador
              Row(
                children: [
                  BaseButton(
                    text: 'Agregar Producto',
                    onPressed: onShowAddProductDialog,
                    width: 150,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BaseTextField(
                      controller: searchController,
                      hintText: 'Buscar producto por nombre...',
                      prefixIcon: Icons.search,
                      onChanged: (value) =>
                          (context as Element).markNeedsBuild(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Título con contador
              Text(
                'Productos Disponibles (${filteredProducts.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Lista de productos
              Expanded(
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          searchText.isEmpty
                              ? AppConstants.noProductsMessage
                              : 'No se encontraron productos con "$searchText"',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return InkWell(
                            onTap: () => onAddProductToCart(product),
                            child: Card(
                              color: Theme.of(context).cardColor,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            '${AppConstants.priceLabel} ${AppConstants.currencySymbol}${product.price.toStringAsFixed(2).replaceAll('.00', '')}',
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
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
