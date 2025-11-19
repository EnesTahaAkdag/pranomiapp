class RouteIndexMapper {
  static int getIndexFromRoute(String route, {bool showIncomeExpense = true}) {
    if (showIncomeExpense) {
      // Tam versiyon index mapping
      switch (route) {
        case '/':
          return 0;

        case '/incomeorder':
        case '/incomeinvoice':
        case '/incomeclaim':
        case '/InComeOrder':
        case '/InComeInvoice':
        case '/InComeClaim':
          return 1;

        case '/expenseorder':
        case '/expenseinvoice':
        case '/expenseclaim':
        case '/ExpenseOrder':
        case '/ExpenseInvoice':
        case '/ExpenseClaim':
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
    } else {
      // E-Invoice only versiyon
      switch (route) {
        case '/':
          return 0;

        case '/Credits':
          return 1;

        case '/OutGoingE-Invoice':
        case '/OutGoingE-Archive':
        case '/OutGoingE-Dispatch':
        case '/ApprovedE-Invoice':
        case '/ApprovedE-Dispatch':
          return 2;

        default:
          return -1;
      }
    }
  }
}