class RouteIndexMapper {
  static int getIndexFromRoute(String route) {
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
        return -1;
    }
  }
}