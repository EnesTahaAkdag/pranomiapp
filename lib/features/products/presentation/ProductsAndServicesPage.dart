import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/ProductsModels/productmodel.dart';

import 'ProductsAndServicesViewModel.dart';

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
      backgroundColor: Colors.grey[100],
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
                        ? Center(
                            child: Text(
                              'Hiç ürün bulunamadı.',
                              style: TextStyle(color: Colors.grey[600]),
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
                                 return const Padding(
                                   padding: EdgeInsets.all(16),
                                   child: Center(child: CircularProgressIndicator()),
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
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator(color: Colors.white,)),
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
          fillColor: Colors.white,
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
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', decimalDigits: 2, symbol: '');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        color: Colors.white,
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
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                              ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
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
                              color: Colors.black87,
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
                    Text('Stok Kodu: ${product.stockCode}', style: const TextStyle(color: Colors.black54)),
                    Text('Stok: ${product.stockAmount}', style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Birim Fiyat: ${currencyFormatter.format(product.price)}₺', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                    Text('Satış Fiyatı: ${currencyFormatter.format(salePrice)}₺', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
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
                _showSnackBar('Geçerli bir stok miktarı girin.', Colors.red);
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
