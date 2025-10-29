import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import '../../di/injection.dart';
import 'app_drawer.dart';
import 'custom_bottom_navigation.dart';
import 'route_index_mapper.dart';

class AppLayout extends StatefulWidget {
  final Widget body;
  final String title;
  final bool showAppBar;

  const AppLayout({
    super.key,
    required this.body,
    required this.title,
    this.showAppBar = true,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  String? openMenuId;
  bool showIncomeExpense = true;
  bool showEDocuments = true;
  String _currentRoute = '/';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMenuVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    setState(() {
      _currentRoute = uri;
      _currentIndex = RouteIndexMapper.getIndexFromRoute(uri);
    });
  }

  Future<void> _loadMenuVisibility() async {
    final prefs = locator<SharedPreferences>();
    final subscriptionType = prefs.getString('subscriptionType');
    final isEInvoiceActive = prefs.getBool('isEInvoiceActive');

    setState(() {
      if (subscriptionType == 'EInvoice') {
        showIncomeExpense = false;
      }
      if (isEInvoiceActive == false) {
        showEDocuments = false;
      }
    });
  }

  void toggleMenu(String menuId) {
    setState(() {
      if (openMenuId == menuId) {
        openMenuId = null;
      } else {
        openMenuId = menuId;
      }
    });
  }

  void _navigateTo(String route) {
    if (route != _currentRoute) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      setState(() {
        _currentRoute = route;
        _currentIndex = RouteIndexMapper.getIndexFromRoute(route);
      });
      context.go(route);
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = RouteIndexMapper.getIndexFromRoute(_currentRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        currentRoute: _currentRoute,
        openMenuId: openMenuId,
        showIncomeExpense: showIncomeExpense,
        showEDocuments: showEDocuments,
        onNavigate: _navigateTo,
        onToggleMenu: toggleMenu,
      ),
      appBar: widget.showAppBar
          ? AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0XFF2A2A2A),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      )
          : null,
      body: widget.body,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        currentRoute: _currentRoute,
        onNavigate: _navigateTo,
        onIndexChanged: _onBottomNavTap,
      ),
    );
  }
}

