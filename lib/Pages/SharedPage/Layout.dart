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
      case '/ProductsandServices':
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
        _currentIndex = getIndexFromRoute(route);
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          _navigateTo(route);
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF3F3F3F),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            width: double.infinity,
            color: const Color(0xFFB00034),
            child: Center(
              child: Image.asset(
                'lib/assets/images/PranomiLogo.png',
                height: 90,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildExpandableTile("Güncel Durum", "Current", [
                  _drawerItem("Genel Bakış", '/'),
                  _drawerItem("Analizler", '/graphs'),
                  _drawerItem("Ödemeler ve Tahsilatlar", '/sayfaC'),
                ]),
                _buildExpandableTile("Stok", "stock", [
                  _drawerItem("Ürünler ve Hizmetler", '/ProductsandServices'),
                  _drawerItem("Masraflar", '/zsdxcf'),
                  _drawerItem("Gelir İrsaliyeleri", '/IncomeWayBill'),
                  _drawerItem("Gider İrsaliyeleri", '/ExpenseWayBill'),
                ]),
                _drawerItems("Cari Hesaplar", '/CustomerAccounts'),
                _drawerItems("Çalışanlar", '/EmployeAccounts'),
                if (showIncomeExpense)
                  _buildExpandableTile("Gelirler", "income", [
                    _drawerItem("Alınan Siparişler", '/InComeOrder'),
                    _drawerItem("Satış Faturası", '/InComeInvoice'),
                    _drawerItem("Satış İade Faturası", '/InComeClaim'),
                  ]),
                if (showIncomeExpense)
                  _buildExpandableTile("Giderler", "u", [
                    _drawerItem("Verilen Siparişler", '/ExpenseOrder'),
                    _drawerItem("Alış Faturası", '/ExpenseInvoice'),
                    _drawerItem("Alış İade Faturası", '/ExpenseClaim'),
                  ]),
                if (showEDocuments)
                  _buildExpandableTile("E-Belgeler", "ğ", [
                    _buildExpandableTile("Giden", "edoc_out", [
                      _drawerItem("E-Faturalar", '/OutGoingE-Invoice'),
                      _drawerItem("E-Arşiv Faturalar", '/OutGoingE-Archive'),
                      _drawerItem("E-İrsaliyeler", '/OutGoingE-Dispatch'),
                    ]),
                    _buildExpandableTile("Gelen", "g", [
                      _drawerItem("E-Faturalar", '/ApprovedE-Invoice'),
                      _drawerItem("E-İrsaliyeler", '/ApprovedE-Dispatch'),
                    ]),
                  ]),
                if (showIncomeExpense)
                  _buildExpandableTile("Nakit", "f", [
                    _drawerItem("Kasa ve Bankalar", '/DepositAndBanks'),
                  ]),
                _drawerItems("Kontör", '/Credits'),
                _drawerItems("Bildirimler", '/Notifications'),
                if (showEDocuments)
                  _buildExpandableTile("Ayarlar", "c", [
                    _drawerItem("Kullanıcılar", '/an'),
                    _buildExpandableTile("Ana Cari Ayarları", "b", [
                      _drawerItem("Ana Cariler", '/am'),
                      _drawerItem("Ana Cari Kaynağı", '/aö'),
                    ]),
                    _drawerItem("API Anahtarım", '/aç'),
                    _drawerItem("Kategoriler", '/ai'),
                    _drawerItem("Talepler", '/aı'),
                    _drawerItem("Genel Ayarlar", '/ao'),
                    _buildExpandableTile("E-Belge Ayarları", "a", [
                      _drawerItem("E-Belge Ekle - Güncelle", '/at'),
                      _drawerItem("E-Belge Bildirimlerim", '/ar'),
                      _drawerItem("E-Belge Serileri", '/aw'),
                      _drawerItem("E-Belge Şablon", '/aü'),
                    ]),
                  ]),
                _drawerItems("Duyurularım", '/Announcements'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItems(String title, String route) {
    final isActive = route == _currentRoute;
    return Container(
      color: isActive ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.white)),
        tileColor:
            _currentRoute == route
                ? const Color(0xFFB00034)
                : Colors.transparent,
        onTap: () => _navigateTo(route),
      ),
    );
  }

  Widget _drawerItem(String title, String route) {
    final isActive = route == _currentRoute;
    return Container(
      color: isActive ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.white)),
        tileColor:
            _currentRoute == route
                ? const Color(0xFFB00034)
                : Colors.transparent,
        onTap: () => _navigateTo(route),
      ),
    );
  }

  Widget _buildExpandableTile(String title, String id, List<Widget> children) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF2C2C2C),
      collapsedBackgroundColor: const Color(0xFF3F3F3F),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      initiallyExpanded: openMenuId == id,
      onExpansionChanged: (_) => toggleMenu(id),
      children: children,
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
                backgroundColor: const Color(0xFF3F3F3F),
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
              _navigateTo('/');
              break;
            case 1:
              _navigateTo('/ProductsandServices');
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
        backgroundColor: const Color(0xFF3F3F3F),
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
}
