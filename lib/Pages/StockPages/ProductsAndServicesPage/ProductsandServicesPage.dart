import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/ProductsModels/productmodel.dart';
import 'package:pranomiapp/Models/ProductsModels/productstockupdatemodel.dart';
import 'package:pranomiapp/services/ProductServices/ProductsandServicesPageServices.dart';
import 'package:pranomiapp/services/ProductServices/ProductsandServicesPageStockUpdateService.dart';

import '../../../core/di/Injection.dart';

class ProductsandServicesPage extends StatefulWidget {
  const ProductsandServicesPage({super.key});

  @override
  State<ProductsandServicesPage> createState() =>
      _ProductsandServicesPageState();
}

class _ProductsandServicesPageState extends State<ProductsandServicesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<ProductResponseModel> _products = [];

  bool _isLoading = false;
  bool _hasMore = true;

  int _page = 0;
  final int _size = 20;
  String _searchText = '';

  final _productsandServicesPageStockUpdateService =
      locator<ProductsandServicesPageStockUpdateService>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _products.clear();
      _hasMore = true;
    }

    setState(() => _isLoading = true);

    try {
      final resp = await ProductsandServicesPageServices().fetchProducts(
        query: _searchText.isNotEmpty ? _searchText : null,
        page: _page,
        size: _size,
      );

      setState(() {
        _products.addAll(resp);
        _page++;
        if (resp.length < _size) _hasMore = false;
      });
    } catch (e) {
      _showSnackBar('Veri çekme hatası: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchProducts(reset: true),
                child:
                    _products.isEmpty && !_isLoading
                        ? Center(
                          child: Text(
                            'Hiç ürün bulunamadı.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          itemCount: _products.length + (_isLoading ? 1 : 0),
                          itemBuilder: (ctx, idx) {
                            if (idx < _products.length) {
                              return _buildProductItem(_products[idx]);
                            }
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
              ),
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
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          hintText: 'Ürün adı ya da stok kodu...',
          suffixIcon:
              _searchText.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchText = '');
                      _fetchProducts(reset: true);
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
        onChanged: (val) {
          setState(() => _searchText = val);
        },
        onSubmitted: (_) => _fetchProducts(reset: true),
      ),
    );
  }

  Widget _buildProductItem(ProductResponseModel product) {
    double salePrice = product.price * (1 + product.vatRate / 100);
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      decimalDigits: 2,
      symbol: '',
    );
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
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: (product.imageUrl.isNotEmpty)
                      ? Image.network(
                          product.imageUrl,
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
                    Text(
                      'Stok Kodu: ${product.stockCode}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'Stok: ${product.stockAmount}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Birim Fiyat: ${currencyFormatter.format(product.price)}₺',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      // ignore: unnecessary_brace_in_string_interps
                      'Satış Fiyatı: ${currencyFormatter.format(salePrice)}₺',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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

  void _showProductActions(ProductResponseModel product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Stok Güncelle'),
                  onTap: () {
                    Navigator.pop(context);
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
    final stockController = TextEditingController(
      text: product.stockAmount.toString(),
    );
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('${product.productName} - Stok Güncelle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Yeni Stok'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context,rootNavigator: true).pop(),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newStock = int.tryParse(stockController.text);
                  if (newStock == null) {
                    _showSnackBar(
                      'Geçerli bir stok miktarı girin.',
                      Colors.red,
                    );
                    return;
                  }

                  Navigator.of(context,rootNavigator: true).pop();

                  final result =
                      await _productsandServicesPageStockUpdateService
                          .updateStock(
                            ProductStockUpdateModel(
                              productId: product.productId,
                              stockAmount: newStock,
                              description: commentController.text.trim(),
                            ),
                          );

                  _showSnackBar(
                    result != null
                        ? 'Stok güncellendi.'
                        : 'Stok güncelleme başarısız.',
                    result != null ? Colors.green : Colors.red,
                  );

                  if (result != null) _fetchProducts(reset: true);
                },
                child: const Text('Güncelle'),
              ),
            ],
          ),
    );
  }
}
