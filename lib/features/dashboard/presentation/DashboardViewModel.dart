import 'package:flutter/material.dart';
import 'package:pranomiapp/core/di/Injection.dart';
import 'package:pranomiapp/features/dashboard/data/DashboardModel.dart';
import 'package:pranomiapp/features/dashboard/data/DashboardService.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService = locator<DashboardService>();

  DashboardItem? _dashboardItem;
  DashboardItem? get dashboardItem => _dashboardItem;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DashboardViewModel() {
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    // Notify listeners to show loading indicator, especially for refresh
    notifyListeners();

    try {
      final response = await _dashboardService.fetchDashboard();
      if (response != null && response.success) {
        _dashboardItem = response.item;
      } else {
        _error = response?.errorMessages.join('\\n') ?? "Veriler alınamadı.";
      }
    } catch (e) {
      _error = "Bir hata oluştu: \${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
