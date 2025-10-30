import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/formatters.dart';

import '../domain/product_model.dart';
import 'products_and_services_view_model.dart';

class ProductsAndServicesPage extends StatefulWidget {
  const ProductsAndServicesPage({super.key});

  @override
  State<ProductsAndServicesPage> createState() =>
      _ProductsAndServicesPageState();
}

class _ProductsAndServicesPageState extends State<ProductsAndServicesPage> {
  late final ProductsAndServicesViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProductsAndServicesViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _scrollController.addListener(() => _viewModel.handleScroll(_scrollController));
  }

  void _onViewModelChanged() {
    if (mounted) {
      if (_viewModel.snackBarMessage != null) {
        _showSnackBar(_viewModel.snackBarMessage!, _viewModel.snackBarColor);
        _viewModel.clearSnackBarMessage();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray100,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _viewModel.fetchProducts(reset: true),
                    child: _viewModel.products.isEmpty && !_viewModel.isLoading
                        ? const Center(
                            child: Text(
                              'Hiç ürün bulunamadı.',
                              style: TextStyle(color: AppTheme.gray600),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _viewModel.products.length + (_viewModel.hasMore ? 1 : 0),
                            itemBuilder: (ctx, idx) {
                              if (idx < _viewModel.products.length) {
                                return _buildProductItem(_viewModel.products[idx]);
                              }
                              if (_viewModel.hasMore) {
                                 return  Padding(
                                   padding: const EdgeInsets.all(16),
                                   child: Center(child:  LoadingAnimationWidget.staggeredDotsWave(
                                     // LoadingAnimationwidget that call the
                                     color: AppTheme.accentColor, // staggereddotwave animation
                                     size: 50,
                                   )),
                                 );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ),
              ],
            ),
            if (_viewModel.isUpdating)
              Container(
                color: AppTheme.blackOverlay50,
                child:  Center(child:  LoadingAnimationWidget.staggeredDotsWave(
                  // LoadingAnimationwidget that call the
                  color: AppTheme.accentColor, // staggereddotwave animation
                  size: 50,
                )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _viewModel.searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.white,
          prefixIcon: const Icon(Icons.search),
          hintText: 'Ürün adı ya da stok kodu...',
          suffixIcon: _viewModel.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _viewModel.clearSearchAndFetch(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onSubmitted: (text) => _viewModel.onSearchSubmitted(text),
      ),
    );
  }

  Widget _buildProductItem(ProductResponseModel product) {
    double salePrice = product.price * (1 + product.vatRate / 100);

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
                  child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child:  LoadingAnimationWidget.staggeredDotsWave(
                                // LoadingAnimationwidget that call the
                                color: AppTheme.accentColor, // staggereddotwave animation
                                size: 50,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppTheme.gray200,
                                child: const Icon(Icons.broken_image_outlined, size: 40, color: AppTheme.gray600),
                              ),
                        )
                      : Container(
                          color: AppTheme.gray200,
                          child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppTheme.gray600),
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
                          onPressed: () => _showProductActions(product),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Stok Kodu: ${product.stockCode}', style: const TextStyle(color: AppTheme.textBlack54)),
                    Text('Stok: ${product.stockAmount}', style: const TextStyle(color: AppTheme.textBlack87)),
                    const SizedBox(height: 4),
                    Text('Birim Fiyat: ${AppFormatters.formatCurrency(product.price)}₺', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textBlack87)),
                    Text('Satış Fiyatı: ${AppFormatters.formatCurrency(salePrice)}₺', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textBlack87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductActions(ProductResponseModel product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Stok Güncelle'),
              onTap: () {
                Navigator.pop(modalContext);
                _showStockUpdateDialog(context, product);
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
  ) {
    final stockController = TextEditingController(text: product.stockAmount.toString());
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${product.productName} - Stok Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Yeni Stok Miktarı'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Açıklama (Opsiyonel)'),
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
                _showSnackBar('Geçerli bir stok miktarı girin.', AppTheme.errorColor);
                return;
              }
              Navigator.pop(dialogContext);
              await _viewModel.updateStock(product, newStock, commentController.text.trim());
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }
}
