import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/products_view_model.dart';
import '../shared/widgets/app_empty_state.dart';
import 'widgets/delete_product_dialog.dart';
import 'widgets/product_form_dialog.dart';
import 'widgets/product_row.dart';
import 'widgets/product_table_header.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductFormDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'إضافة منتج',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<ProductsViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPageHeader(
                    context,
                    viewModel,
                  ),

                  const SizedBox(height: 20),

                  _buildSearchField(
                    context,
                    viewModel,
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : viewModel.products.isEmpty
                        ? _buildEmpty(
                      context,
                      viewModel,
                    )
                        : _buildProductsList(
                      context,
                      viewModel,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(
      BuildContext context,
      ProductsViewModel viewModel,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.inventory_2_rounded,
            color: colorScheme.primary,
            size: 28,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدارة المنتجات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'إدارة المنتجات والمخزون والأسعار',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${viewModel.products.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'منتج',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(
      BuildContext context,
      ProductsViewModel viewModel,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: viewModel.search,
        decoration: InputDecoration(
          hintText: 'ابحث باسم المنتج أو الباركود...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
          ),
          suffixIcon: viewModel.searchQuery.isNotEmpty
              ? IconButton(
            onPressed: () {
              viewModel.search('');
            },
            icon: const Icon(
              Icons.clear_rounded,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(
      BuildContext context,
      ProductsViewModel viewModel,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProductTableHeader(),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount: viewModel.products.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
              itemBuilder: (context, index) {
                final product = viewModel.products[index];

                return ProductRow(
                  product: product,
                  onEdit: () {
                    showProductFormDialog(
                      context,
                      product: product,
                    );
                  },
                  onDelete: () async {
                    final confirmed =
                    await showDeleteProductDialog(
                      context,
                      product,
                    );

                    if (confirmed && context.mounted) {
                      await viewModel.deleteProduct(
                        product.id!,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(
      BuildContext context,
      ProductsViewModel viewModel,
      ) {
    final hasSearch =
        viewModel.searchQuery.trim().isNotEmpty;

    return Center(
      child: AppEmptyState(
        icon: hasSearch
            ? Icons.search_off_rounded
            : Icons.inventory_2_outlined,
        title: hasSearch
            ? 'مفيش منتجات مطابقة للبحث'
            : 'مفيش منتجات لسه',
        message: hasSearch
            ? 'جرب البحث باسم أو باركود مختلف'
            : 'ابدأ بإضافة أول منتج للمخزون',
        action: hasSearch
            ? null
            : ElevatedButton.icon(
          onPressed: () {
            showProductFormDialog(context);
          },
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'إضافة منتج',
          ),
        ),
      ),
    );
  }
}