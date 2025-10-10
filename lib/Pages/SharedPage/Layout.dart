import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

      case '/incomeorder':
      case '/incomeinvoice':
      case '/incomeclaim':
        return 1;

      case '/expenseorder':
      case '/expenseinvoice':
      case '/expenseclaim':
        return 2;

      case '/OutGoingE-Invoice':
      case '/OutGoingE-Archive':
      case '/OutGoingE-Dispatch':
      case '/ApprovedE-Invoice':
      case '/ApprovedE-Dispatch':
        return 3;

      default:
        return -1; // 👈 Drawer’dan açılan diğer sayfalar için
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

  Future<void> _showEDocumentsSubMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2c2c2c),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white,
                ),
                child: ExpansionTile(
                  title: const Text(
                    "Giden",
                    style: TextStyle(color: Colors.white),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    _incomeListTile("E-Faturalar", '/OutGoingE-Invoice'),
                    _incomeListTile("E-Arşiv Faturalar", '/OutGoingE-Archive'),
                    _incomeListTile("E-İrsaliyeler", '/OutGoingE-Dispatch'),
                  ],
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white,
                ),
                child: ExpansionTile(
                  title: const Text(
                    "Gelen",
                    style: TextStyle(color: Colors.white),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    _incomeListTile("E-Faturalar", '/ApprovedE-Invoice'),
                    _incomeListTile("E-İrsaliyeler", '/ApprovedE-Dispatch'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
                _buildExpandableTile(
                  "icon_tachometer.svg",
                  "Güncel Durum",
                  "Current",
                  [
                    _drawerItem("icon_signature.svg", "Genel Bakış", '/'),
                    _drawerItem("icon_chart.svg", "Analizler", '/graphs'),
                    _drawerItem(
                      "icon_money_bill.svg",
                      "Ödemeler ve Tahsilatlar",
                      '/sayfaC',
                    ),
                  ],
                ),
                _buildExpandableTile("icon_archieve.svg", "Stok", "stock", [
                  _drawerItem(
                    "icon_cubes.svg",
                    "Ürünler ve Hizmetler",
                    '/ProductsandServices',
                  ),
                  _drawerItem("icon_briefcase.svg", "Masraflar", '/zsdxcf'),
                  _drawerItem(
                    "icon_file_invoice.svg",
                    "Gelir İrsaliyeleri",
                    '/IncomeWayBill',
                  ),
                  _drawerItem(
                    "icon_file_lines.svg",
                    "Gider İrsaliyeleri",
                    '/ExpenseWayBill',
                  ),
                ]),
                _drawerItems(
                  "icon_users.svg",
                  "Cari Hesaplar",
                  '/CustomerAccounts',
                ),
                _drawerItems(
                  "icon_usertie.svg",
                  "Çalışanlar",
                  '/EmployeAccounts',
                ),
                if (showIncomeExpense)
                  _buildExpandableTile(
                    "icon_caret_square_down.svg",
                    "Gelirler",
                    "income",
                    [
                      _drawerItem(
                        "icon_file_contract.svg",
                        "Alınan Siparişler",
                        '/InComeOrder',
                      ),
                      _drawerItem(
                        "icon_file_download.svg",
                        "Satış Faturası",
                        '/InComeInvoice',
                      ),
                      _drawerItem(
                        "icon_file_upload.svg",
                        "Satış İade Faturası",
                        '/InComeClaim',
                      ),
                    ],
                  ),
                if (showIncomeExpense)
                  _buildExpandableTile(
                    "icon_caret_square_up.svg",
                    "Giderler",
                    "u",
                    [
                      _drawerItem(
                        "icon_file_contract.svg",
                        "Verilen Siparişler",
                        '/ExpenseOrder',
                      ),
                      _drawerItem(
                        "icon_file_download.svg",
                        "Alış Faturası",
                        '/ExpenseInvoice',
                      ),
                      _drawerItem(
                        "icon_file_upload.svg",
                        "Alış İade Faturası",
                        '/ExpenseClaim',
                      ),
                    ],
                  ),
                if (showEDocuments)
                  _buildExpandableTile(
                    "icon_note_sticky.svg",
                    "E-Belgeler",
                    "ğ",
                    [
                      _buildExpandableTile(
                        "icon_arrow_up.svg",
                        "Giden",
                        "edoc_out",
                        [
                          _drawerItem(
                            "icon_file_invoice.svg",
                            "E-Faturalar",
                            '/OutGoingE-Invoice',
                          ),
                          _drawerItem(
                            "icon_file_contract.svg",
                            "E-Arşiv Faturalar",
                            '/OutGoingE-Archive',
                          ),
                          _drawerItem(
                            "icon_file_lines.svg",
                            "E-İrsaliyeler",
                            '/OutGoingE-Dispatch',
                          ),
                        ],
                      ),
                      _buildExpandableTile(
                        "icon_arrow_down.svg",
                        "Gelen",
                        "g",
                        [
                          _drawerItem(
                            "icon_file_invoice.svg",
                            "E-Faturalar",
                            '/ApprovedE-Invoice',
                          ),
                          _drawerItem(
                            "icon_file_lines.svg",
                            "E-İrsaliyeler",
                            '/ApprovedE-Dispatch',
                          ),
                        ],
                      ),
                    ],
                  ),
                if (showIncomeExpense)
                  _buildExpandableTile("icon_money.svg", "Nakit", "f", [
                    _drawerItem(
                      "icon_building.svg",
                      "Kasa ve Bankalar",
                      '/DepositAndBanks',
                    ),
                  ]),
                _drawerItems("icon_lira.svg", "Kontör", '/Credits'),
                _drawerItems("icon_bell.svg", "Bildirimler", '/Notifications'),
                _drawerItems(
                  "icon_bullhorn.svg",
                  "Duyurularım",
                  '/Announcements',
                ),
                _drawerItems("icon_logout.svg", "Çıkış Yap", '/login'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItems(String imagePath, String title, String route) {
    final isActive = route == _currentRoute;
    return Container(
      color: isActive ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        leading: SvgPicture.asset(
          'lib/assets/images/$imagePath',
          width: 32,
          height: 32,
          alignment: Alignment.center,
          colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        tileColor:
            _currentRoute == route
                ? const Color(0xFFB00034)
                : Colors.transparent,
        onTap: () => _navigateTo(route),
      ),
    );
  }

  Widget _drawerItem(String imagePath, String title, String route) {
    final isActive = route == _currentRoute;
    return Container(
      color: isActive ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        leading: SvgPicture.asset(
          'lib/assets/images/$imagePath',
          width: 32,
          height: 32,
          alignment: Alignment.center,
          colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        tileColor:
            _currentRoute == route
                ? const Color(0xFFB00034)
                : Colors.transparent,
        onTap: () => _navigateTo(route),
      ),
    );
  }

  Widget _buildExpandableTile(
    String imagePath,
    String title,
    String id,
    List<Widget> children,
  ) {
    return ExpansionTile(
      leading: SvgPicture.asset(
        'lib/assets/images/$imagePath',
        width: 32,
        height: 32,
        alignment: Alignment.center,
        colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
      ),
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
        currentIndex: _currentIndex >= 0 ? _currentIndex : 0,
        selectedItemColor:
            _currentIndex >= 0 ? const Color(0xFFB00034) : Colors.white,
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) async {
          switch (index) {
            case 0:
              _navigateTo('/');

            case 1:
              await _showIncomeSubMenu(context);
              setState(() {
                _currentIndex = getIndexFromRoute(_currentRoute);
              });
              break;
            case 2:
              await _showExpenseSubMenu(context);
              setState(() {
                _currentIndex = getIndexFromRoute(_currentRoute);
              });
              break;
            case 3:
              await _showEDocumentsSubMenu(context);
              setState(() {
                _currentIndex = getIndexFromRoute(_currentRoute);
              });
              break;
          }
        },
        backgroundColor: const Color(0xFF3F3F3F),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_sharp),
            label: 'Gelirler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Giderler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_sharp),
            label: 'E-Belgeler',
          ),
        ],
      ),
    );
  }
}
