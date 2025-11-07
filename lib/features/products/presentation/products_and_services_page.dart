import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/formatters.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/core/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

import '../domain/product_model.dart';
import 'products_and_services_view_model.dart';

/// Products and Services Page - MVVM Pattern with Provider
/// Using ChangeNotifierProvider to properly manage ViewModel lifecycle
class ProductsAndServicesPage extends StatelessWidget {
  const ProductsAndServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductsAndServicesViewModel(),
      child: const _ProductsAndServicesView(),
    );
  }
}

/// Main view widget - Listens to ViewModel changes via Provider
class _ProductsAndServicesView extends StatefulWidget {
  const _ProductsAndServicesView();

  @override
  State<_ProductsAndServicesView> createState() =>
      _ProductsAndServicesViewState();
}

class _ProductsAndServicesViewState extends State<_ProductsAndServicesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Access ViewModel via Provider context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = context.read<ProductsAndServicesViewModel>();
    viewModel.handleScroll(_scrollController);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsAndServicesViewModel>(
      builder: (context, viewModel, child) {
        // Handle snackbar messages
        if (viewModel.snackBarMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(viewModel.snackBarMessage!, viewModel.snackBarColor);
            viewModel.clearSnackBarMessage();
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.gray100,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildSearchBar(viewModel),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.fetchProducts(reset: true),
                        child:
                            viewModel.products.isEmpty && !viewModel.isLoading
                                ? const Center(
                                  child: Text(
                                    'Hiç ürün bulunamadı.',
                                    style: TextStyle(color: AppTheme.gray600),
                                  ),
                                )
                                : ListView.builder(
                                  controller: _scrollController,
                                  itemCount:
                                      viewModel.products.length +
                                      (viewModel.hasMore ? 1 : 0),
                                  itemBuilder: (ctx, idx) {
                                    if (idx < viewModel.products.length) {
                                      return ProductListItem(
                                        key: ValueKey(
                                          viewModel.products[idx].productId,
                                        ),
                                        product: viewModel.products[idx],
                                        onMorePressed:
                                            () => _showProductActions(
                                              viewModel.products[idx],
                                              viewModel,
                                            ),
                                      );
                                    }
                                    if (viewModel.hasMore) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: AppLoadingIndicator(),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.isUpdating)
                  Container(
                    color: AppTheme.blackOverlay50,
                    child: const Center(child: AppLoadingIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ProductsAndServicesViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomSearchBar(
        controller: viewModel.searchController,
        hintText: 'Ürün adı ya da stok kodu ara...',
        onClear: () => viewModel.clearSearchAndFetch(),
        onSubmitted: (text) => viewModel.onSearchSubmitted(text),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  void _showProductActions(
    ProductResponseModel product,
    ProductsAndServicesViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (modalContext) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Stok Güncelle'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _showStockUpdateDialog(context, product, viewModel);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showStockUpdateDialog(
    BuildContext context,
    ProductResponseModel product,
    ProductsAndServicesViewModel viewModel,
  ) {
    final stockController = TextEditingController(
      text: product.stockAmount.toString(),
    );
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('${product.productName} - Stok Güncelle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: stockController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Yeni Stok Miktarı',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (Opsiyonel)',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newStock = double.tryParse(stockController.text);
                  if (newStock == null) {
                    _showSnackBar(
                      'Geçerli bir stok miktarı girin.',
                      AppTheme.errorColor,
                    );
                    return;
                  }
                  Navigator.pop(dialogContext);
                  await viewModel.updateStock(
                    product,
                    newStock,
                    commentController.text.trim(),
                  );
                },
                child: const Text('Güncelle'),
              ),
            ],
          ),
    );
  }
}

/// Optimized Product List Item Widget
/// Extracted to separate StatelessWidget for better performance and reusability
class ProductListItem extends StatelessWidget {
  final ProductResponseModel product;
  final VoidCallback onMorePressed;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final salePrice = product.price * (1 + product.vatRate / 100);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        color: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child:
                      (product.imageUrl != null && product.imageUrl.isNotEmpty)
                          ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,

                        placeholder: (context, url) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                Colors.amberAccent,
                              ),
                            ),
                          );
                        },

                        errorWidget: (context, imageUrl, error) {
                          // URL .svg ile bitiyorsa SVG olarak göster
                          if (imageUrl.toLowerCase().endsWith('.svg')) {
                            return SvgPicture.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.amberAccent),
                                ),
                              ),
                            );
                          }

                          // SVG değilse broken image icon göster
                          return Container(
                            color: AppTheme.gray200,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: AppTheme.gray600,
                            ),
                          );
                        },
                      )
                          : Container(
                            color: AppTheme.gray200,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 40,
                              color: AppTheme.gray600,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: onMorePressed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok Kodu: ${product.stockCode}',
                      style: const TextStyle(color: AppTheme.textBlack54),
                    ),
                    Text(
                      'Stok: ${product.stockAmount}',
                      style: const TextStyle(color: AppTheme.textBlack87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Birim Fiyat: ${AppFormatters.formatCurrency(product.price)}₺',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textBlack87,
                      ),
                    ),
                    Text(
                      'Satış Fiyatı: ${AppFormatters.formatCurrency(salePrice)}₺',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textBlack87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
