import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/ProductsModels/productmodel.dart';
import 'package:pranomiapp/Models/ProductsModels/productstockupdatemodel.dart';
import 'package:pranomiapp/services/ProductServices/ProductService.dart';
import 'package:pranomiapp/services/ProductServices/ProductStockUpdateService.dart';
import '../../../core/di/Injection.dart';

class ProductsAndServicesViewModel extends ChangeNotifier {
  final ProductService _productsService =
      locator<ProductService>();
  final ProductStockUpdateService _stockUpdateService =
      locator<ProductStockUpdateService>();

  final List<ProductResponseModel> _products = [];

  List<ProductResponseModel> get products => _products;

  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isUpdating = false;

  bool get isUpdating => _isUpdating;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

  int _page = 0;
  final int _size = 20;
  String _searchText = '';

  String? _snackBarMessage;

  String? get snackBarMessage => _snackBarMessage;
  Color _snackBarColor = Colors.green;

  Color get snackBarColor => _snackBarColor;

  ProductsAndServicesViewModel() {
    fetchProducts();
    searchController.addListener(() {
      _searchText = searchController.text;
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void clearSnackBarMessage() {
    _snackBarMessage = null;
  }

  void _showSnackBar(String message, Color color) {
    _snackBarMessage = message;
    _snackBarColor = color;
    notifyListeners();
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (_isLoading && !reset) return;

    if (reset) {
      _page = 0;
      _products.clear();
      _hasMore = true;
    }
    _setLoading(true);

    try {
      final response = await _productsService.fetchProducts(
        query: _searchText.isNotEmpty ? _searchText : null,
        page: _page,
        size: _size,
      );

      _products.addAll(response);
      _page++;
      if (response.length < _size) {
        _hasMore = false;
      }
    } catch (e) {
      _hasMore = false;
      _showSnackBar('Veri çekme hatası: $e', Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  void handleScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      fetchProducts();
    }
  }

  void onSearchSubmitted(String text) {
    _searchText = text;
    fetchProducts(reset: true);
  }

  void clearSearchAndFetch() {
    searchController.clear();
    _searchText = '';
    fetchProducts(reset: true);
  }

  Future<void> updateStock(
    ProductResponseModel product,
    double newStock,
    String description,
  ) async {
    _setUpdating(true);
    try {
      final result = await _stockUpdateService.updateStock(
        ProductStockUpdateModel(
          productId: product.productId,
          stockAmount: newStock,
          description: description,
        ),
      );

      if (result != null) {
        _showSnackBar('Stok güncellendi.', Colors.green);
        fetchProducts(reset: true);
      } else {
        _showSnackBar('Stok güncelleme başarısız.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Stok güncellenirken hata oluştu: $e', Colors.red);
    } finally {
      _setUpdating(false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
