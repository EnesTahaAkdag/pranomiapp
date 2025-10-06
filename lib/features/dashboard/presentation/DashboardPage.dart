import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/core/di/Injection.dart';
import 'package:pranomiapp/features/dashboard/data/DashboardModel.dart';
import 'package:pranomiapp/features/dashboard/data/DashboardService.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardService _dashboardService;
  DashboardItem? _dashboardItem;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dashboardService = locator<DashboardService>();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _dashboardService.fetchDashboard();
      if (mounted) {
        if (response != null && response.success) {
          setState(() {
            _dashboardItem = response.item;
          });
        } else {
          setState(() {
            _error = response?.errorMessages.join('\n') ?? "Veriler alınamadı.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Bir hata oluştu: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashboardItem dashboard =
        _dashboardItem ??
            DashboardItem(
              totalCashAccountBalance: 0,
              totalBankAccountBalances: [],
              activeCustomerAccountReceiving: 0,
              activeCustomerAccountPayment: 0,
              nextCustomerAccountReceiving: 0,
              nextCustomerAccountPayment: 0,
              totalIncomeAmount: 0,
              totalExpenseAmount: 0,
              activeInvoiceReceiving: 0,
              nextInvoiceReceiving: 0,
              activeInvoicePayment: 0,
              nextInvoicePayment: 0,
              activeChequeReceiving: 0,
              nextChequeReceiving: 0,
              activeChequePayment: 0,
              nextChequePayment: 0,
              activeDeedReceiving: 0,
              nextDeedReceiving: 0,
              activeDeedPayment: 0,
              nextDeedPayment: 0,
            );
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DashboardCard(
              dashboardTitle: "Güncel",
              dashboardItem: dashboard,
            ),
            const SizedBox(height: 16),
            DashboardNextCard(
              dashboardItem: dashboard,
            ),
          ],
        ),
      ),
    );
  }

}

class DashboardNextCard extends StatelessWidget {
  final DashboardItem dashboardItem;

  const DashboardNextCard({super.key, required this.dashboardItem});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    String bankBalance =
    dashboardItem.totalBankAccountBalances.isNotEmpty
        ? formatter.format(
      dashboardItem.totalBankAccountBalances.first.totalBankAccountBalance,
    )
        : formatter.format(0);

    return Card(
      elevation: 4,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Gelecek Dönem (${_getNextMonthYear()})"),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Varlıklar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Varlıklar",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Kasa",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: formatter.format(
                          dashboardItem.totalCashAccountBalance,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Çek",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: formatter.format(
                          dashboardItem.nextChequeReceiving,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Senet",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: formatter.format(
                          dashboardItem.nextDeedReceiving,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Banka",
                        imagePath: 'lib/assets/images/icon_bank.svg',
                        amount: bankBalance,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Borçlar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Borçlar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Borçlar",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: formatter.format(
                          dashboardItem.nextCustomerAccountPayment,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Çekler",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: formatter.format(
                          dashboardItem.nextChequePayment,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Senetler",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: formatter.format(
                          dashboardItem.nextDeedPayment,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String dashboardTitle;
  final DashboardItem dashboardItem;

  const DashboardCard({
    super.key,
    required this.dashboardTitle,
    required this.dashboardItem,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    String bankBalance =
    dashboardItem.totalBankAccountBalances.isNotEmpty
        ? formatter.format(
      dashboardItem
          .totalBankAccountBalances
          .first
          .totalBankAccountBalance,
    )
        : formatter.format(0);

    return Card(
      elevation: 4,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Güncel (${_getCurrentMonthYear()})"),

            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Varlıklar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Varlıklar",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Kasa",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: formatter.format(
                          dashboardItem.totalCashAccountBalance,
                        ),
                      ),
                      SizedBox(height: 16),

                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Çek",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: formatter.format(
                          dashboardItem.activeChequeReceiving,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Senet",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: formatter.format(
                          dashboardItem.activeDeedReceiving,
                        ),
                      ),
                      SizedBox(height: 16),

                      DashboardListItem(
                        dashboardTitle: "Banka",
                        imagePath: 'lib/assets/images/icon_bank.svg',
                        amount: bankBalance,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Borçlar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Borçlar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Borçlar",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: formatter.format(
                          dashboardItem.activeCustomerAccountPayment,
                        ),
                      ),
                      SizedBox(height: 16),

                      DashboardListItem(
                        dashboardTitle: "Ödenecek Çekler",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: formatter.format(
                          dashboardItem.activeChequePayment,
                        ),
                      ),
                      SizedBox(height: 16),

                      DashboardListItem(
                        dashboardTitle: "Ödenecek Senetler",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: formatter.format(
                          dashboardItem.activeDeedPayment,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardListItem extends StatelessWidget {
  final String dashboardTitle;
  final String imagePath;
  final String amount;

  const DashboardListItem({
    super.key,
    required this.dashboardTitle,
    required this.imagePath,
    required this.amount,
  });

  // Helper to parse formatted amount string to double.
  double _parseAmount(String formattedAmount) {
    // Remove currency symbol, spaces, dots for thousands, replace comma with dot.
    String cleaned = formattedAmount
        .replaceAll('₺', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    // There may still be decimals, e.g. 1234.56
    return double.tryParse(cleaned) ?? 0.0;
  }

  // Returns color based on rules.
  Color _getAmountColor(String dashboardTitle, double amount) {
    // Varlıklar items
    final varliklarTitles = [
      "Kasa",
      "Cari Hesap  \n Çek",
      "Cari Hesap  \n Senet",
      "Banka",
    ];
    // Borçlar items
    final borclarTitles = [
      "Cari Borçlar",
      "Ödenecek Çekler",
      "Ödenecek Senetler",
    ];
    // If Varlıklar and amount==0 -> green
    if (varliklarTitles.contains(dashboardTitle) && amount == 0) {
      return Colors.green;
    }
    // If Borçlar and amount==0 -> red
    if (borclarTitles.contains(dashboardTitle) && amount == 0) {
      return Colors.red;
    }
    // Otherwise: positive → green, negative → red
    if (amount > 0) {
      return Colors.green;
    } else if (amount < 0) {
      return Colors.red;
    } else {
      // Fallback: default text color
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedAmount = _parseAmount(amount);
    final absAmount = parsedAmount.abs();
    final color = _getAmountColor(dashboardTitle, parsedAmount);
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final formattedAbsAmount = formatter.format(absAmount);
    return Row(
      children: [
        SvgPicture.asset(
          imagePath,
          width: 32,
          height: 32,
          alignment: Alignment.center,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dashboardTitle,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                formattedAbsAmount,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _getCurrentMonthYear() {
  return DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now());
}

String _getNextMonthYear() {
  DateTime now = DateTime.now();
  int year = now.month == 12 ? now.year + 1 : now.year;
  int month = now.month == 12 ? 1 : now.month + 1;
  final next = DateTime(year, month);
  return DateFormat('MMMM yyyy', 'tr_TR').format(next);
}
