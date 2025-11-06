class RouteTitles {
  static const Map<String, String> _routeTitles = {
    '/': 'Genel Bakış',
    '/ProductsandServices': 'Ürünler ve Hizmetler',
    '/InComeInvoice': 'Gelen Faturalar',
    '/ExpenseInvoice': 'Giden Faturalar',
    '/InComeOrder': 'Gelen Siparişler',
    '/ExpenseOrder': 'Giden Siparişler',
    '/IncomeWayBill': 'Gelen İrsaliyeler',
    '/InComeClaim': 'Satış İade Faturası',
    '/ExpenseClaim': 'Alış İade Faturası',
    '/ExpenseWayBill': 'Giden İrsaliyeler',
    '/ApprovedE-Dispatch': 'Gelen E-İrsaliyeler',
    '/ApprovedE-Invoice': 'Gelen E-Faturalar',
    '/OutGoingE-Dispatch': 'Giden E-İrsaliyeler',
    '/OutGoingE-Archive': 'Giden E-Arşiv Faturalar',
    '/OutGoingE-Invoice': 'Giden E-Faturalar',
    '/CustomerAccounts': 'Cari Hesaplar',
    '/EmployeAccounts': 'Çalışanlar',
    '/SupplierAccounts': 'Tedarikçiler',
    '/DepositAndBanks': 'Kasa Ve Bankalar',
    '/Announcements': 'Duyurular',
    '/Credits': 'Kontörlerim',
    '/Notifications': 'Bildirimler',
    '/incomeinvoice': 'Gelen Faturalar',
    '/incomeorder': 'Gelen Siparişler',
    '/incomeclaim': 'Satış İade Faturası',
    '/expenseinvoice': 'Giden Faturalar',
    '/expenseorder': 'Giden Siparişler',
    '/expenseclaim': 'Alış İade Faturası',
  };

  static String getTitleForRoute(String path) {
    return _routeTitles[path] ?? 'Sayfa';
  }

  static Map<String, String> get all => _routeTitles;
}