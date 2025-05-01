import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/ProductsModels/productmodel.dart';
import 'package:pranomiapp/Models/ProductsModels/productstockupdatemodel.dart';
import 'package:pranomiapp/services/ProductServices/productservices.dart';
import 'package:pranomiapp/services/ProductServices/productstockupdateservice.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();

  List<ProductResponseModel> _allProducts = [];
  List<ProductResponseModel> _filteredProducts = [];

  String _currentQuery = '';
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  // ignore: unused_field
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    _currentPage = 0;
    _hasMore = true;
    final products = await ProductServices().fetchProducts(
      query: _currentQuery,
      page: _currentPage,
      size: _pageSize,
    );
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final products = await ProductServices().fetchProducts(
      query: _currentQuery,
      page: nextPage,
      size: _pageSize,
    );

    setState(() {
      _isLoadingMore = false;
      if (products.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        _allProducts.addAll(products);
        _filteredProducts.addAll(products);
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadInitial();
    setState(() => _isRefreshing = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _onSearch(String query) {
    _currentQuery = query;
    _loadInitial();
  }

  String _formatNumber(double n) {
    if (n == n.floorToDouble()) return n.toInt().toString();
    return n.toString();
  }

  void _showStockUpdateDialog(
    BuildContext parentContext,
    ProductResponseModel product,
  ) {
    final stockController = TextEditingController(
      text: _formatNumber(product.stockAmount),
    );
    final commentController = TextEditingController();

    showDialog(
      context: parentContext,
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${product.productName} - Stok Güncelle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Yeni Stok Miktarı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (isteğe bağlı)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final newStock = int.tryParse(stockController.text);
                          final comment = commentController.text;
                          if (newStock == null) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Geçerli bir stok miktarı girin.',
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(dialogContext);
                          final model = ProductStockUpdateModel(
                            productId: product.productId,
                            stockAmount: newStock,
                            description: comment,
                          );
                          final success = await ProductStockUpdateService()
                              .updateStock(model);
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                success != null
                                    ? 'Stok başarıyla güncellendi.'
                                    : 'Stok güncelleme başarısız.',
                              ),
                            ),
                          );
                          if (success != null) {
                            _loadInitial();
                          }
                        },
                        child: const Text('Güncelle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onSubmitted: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Ürün adı ya da stok kodu girin...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount:
                      _filteredProducts.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _filteredProducts.length) {
                      final product = _filteredProducts[index];
                      return Dismissible(
                        key: ValueKey(product.productId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          _showStockUpdateDialog(context, product);
                          return false;
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: const Color(0xFFB00034),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.inventory_2,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Stok Güncelle',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading:
                                product.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                            title: Text(
                              product.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Stok Kodu: ${product.stockCode}'),
                                Text(
                                  'Stok: ${_formatNumber(product.stockAmount)}',
                                ),
                                Text(
                                  'Fiyat: ${_formatNumber(product.price)} ${product.currencyCode}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
