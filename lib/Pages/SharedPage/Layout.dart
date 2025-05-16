import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ignore: unused_field
  String? _selectedIncomeSubMenuRoute;
  Set<String> openMenus = {};
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
    final uri =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    setState(() {
      _currentRoute = uri;
      _currentIndex = getIndexFromRoute(uri);
    });
  }

  Future<void> _loadMenuVisibility() async {
    final prefs = await SharedPreferences.getInstance();
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

  int getIndexFromRoute(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/products':
        return 1;
      case '/incomeorder':
      case '/incomeinvoice':
      case '/incomeclaim':
        return 2;
      case '/expenseorder':
      case '/expenseinvoice':
      case '/expenseclaim':
        return 3;
      default:
        return 0;
    }
  }

  void toggleMenu(String menuId) {
    setState(() {
      if (openMenus.contains(menuId)) {
        openMenus.remove(menuId);
      } else {
        final isParent = [
          'current',
          'stock',
          'income',
          'expense',
          'edoc',
        ].contains(menuId);
        if (isParent) {
          openMenus.removeWhere((id) => isParent);
        }

        if (menuId == 'edoc_out') {
          openMenus.remove('edoc_in');
        } else if (menuId == 'edoc_in') {
          openMenus.remove('edoc_out');
        }

        openMenus.add(menuId);
      }
    });
  }

  void _navigateTo(String route) {
    if (route != _currentRoute) {
      setState(() {
        _currentRoute = route;
        _currentIndex = getIndexFromRoute(route);
        _selectedIncomeSubMenuRoute = null;
      });
      context.go(route);
    }
  }

  Future<void> _showIncomeSubMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _incomeListTile("Alınan Siparişler", '/incomeorder'),
            _incomeListTile("Satış Faturası", '/incomeinvoice'),
            _incomeListTile("Satış İade Faturası", '/incomeclaim'),
          ],
        );
      },
    );
  }

  Future<void> _showExpenseSubMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _incomeListTile("Verilen Siparişler", '/expenseorder'),
            _incomeListTile("Alış Faturası", '/expenseinvoice'),
            _incomeListTile("Alış İade Faturası", '/expenseclaim'),
          ],
        );
      },
    );
  }

  Widget _incomeListTile(String title, String route) {
    final bool isSelected = _currentRoute == route;

    return Container(
      color: isSelected ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        leading: const Icon(Icons.arrow_right, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          _navigateTo(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar:
          widget.showAppBar
              ? AppBar(
                title: Text(widget.title),
                backgroundColor: const Color(0xFF2C2C2C),
                leading: Builder(
                  builder:
                      (ctx) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                ),
              )
              : null,
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          switch (index) {
            case 0:
              setState(() => _currentIndex = index);
              _navigateTo('/');
              break;
            case 1:
              setState(() => _currentIndex = index);
              _navigateTo('/products');
              break;
            case 2:
              await _showIncomeSubMenu(context);
              setState(() {
                _currentIndex = getIndexFromRoute(_currentRoute);
              });
              break;
            case 3:
              await _showExpenseSubMenu(context);
              setState(() {
                _currentIndex = getIndexFromRoute(_currentRoute);
              });
              break;
          }
        },
        backgroundColor: const Color(0xFF2C2C2C),
        selectedItemColor: const Color(0xFFB00034),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Ürünler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Gelirler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Giderler',
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C2C2C),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            width: double.infinity,
            color: const Color(0xFFB00034),
            child: Center(
              child: Image.asset(
                'lib/assets/images/PranomiLogo.png',
                height: 70,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildExpandableTile("Güncel Durum", "current", [
                  _drawerItem("Genel Bakış", '/'),
                  _drawerItem("Analizler", '/graphs'),
                  _drawerItem("Ödemeler ve Tahsilatlar", '/sayfaC'),
                ]),
                _buildExpandableTile("Stok", "stock", [
                  _drawerItem("Ürünler ve Hizmetler", '/products'),
                  _drawerItem("Masraflar", '/zsdxcf'),
                  _drawerItem("Gelir İrsaliyeleri", '/incomewaybill'),
                  _drawerItem("Gider İrsaliyeleri", '/expensewaybill'),
                ]),
                if (showIncomeExpense)
                  _buildExpandableTile("Gelirler", "income", [
                    _drawerItem("Alınan Siparişler", '/incomeorder'),
                    _drawerItem("Satış Faturası", '/incomeinvoice'),
                    _drawerItem("Satış İade Faturası", '/incomeclaim'),
                  ]),
                if (showIncomeExpense)
                  _buildExpandableTile("Giderler", "expense", [
                    _drawerItem("Verilen Siparişler", '/expenseorder'),
                    _drawerItem("Alış Faturası", '/expenseinvoice'),
                    _drawerItem("Alış İade Faturası", '/expenseclaim'),
                  ]),
                if (showEDocuments)
                  _buildExpandableTile("E-Belgeler", "edoc", [
                    _buildExpandableTile("Giden", "edoc_out", [
                      _drawerItem("E-Faturalar", '/expenseeinvoice'),
                      _drawerItem("E-Arşiv Faturalar", '/expenseearchive'),
                      _drawerItem("E-İrsaliyeler", '/expenseedispatch'),
                    ]),
                    _buildExpandableTile("Gelen", "edoc_in", [
                      _drawerItem("E-Faturalar", '/incomeeinvoice'),
                      _drawerItem("E-İrsaliyeler", '/incomeedispatch'),
                    ]),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTile(String title, String id, List<Widget> children) {
    final isOpen = openMenus.contains(id);
    return Column(
      children: [
        Container(
          color: isOpen ? const Color(0xFFB00034) : Colors.transparent,
          child: ListTile(
            leading: Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: Colors.white70,
            ),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            onTap: () => toggleMenu(id),
          ),
        ),
        if (isOpen)
          ...children.map(
            (widget) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: widget,
            ),
          ),
      ],
    );
  }

  Widget _drawerItem(String title, String route) {
    final isActive = route == _currentRoute;
    return Container(
      color: isActive ? Colors.white12 : Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _currentRoute = route;
            _currentIndex = getIndexFromRoute(route);
          });
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
