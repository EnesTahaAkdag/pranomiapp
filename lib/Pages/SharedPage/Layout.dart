import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLayout extends StatefulWidget {
  final Widget body;
  final String title;

  const AppLayout({super.key, required this.body, required this.title});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  Set<String> openMenus = {};
  bool showIncomeExpense = true;
  bool showEDocuments = true;
  String _currentRoute = '/';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      body: widget.body,
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C2C2C),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 65, bottom: 20),
            width: double.infinity,
            color: const Color(0xFFB00034),
            child: Center(
              child: Image.asset(
                'lib/assets/images/PranomiLogo.png',
                height: 60,
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
                  _drawerItem("Masraflar", '/products'),
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
          });
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
