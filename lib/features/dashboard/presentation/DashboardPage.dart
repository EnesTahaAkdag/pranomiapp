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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _fetchDashboard, child: const Text("Tekrar Dene")),
              ],
            ),
          ),
        ),
      );
    }

    final DashboardItem dashboard = _dashboardItem ??
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
      body: RefreshIndicator(
        onRefresh: _fetchDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DashboardCard(dashboardTitle: "Güncel", dashboardItem: dashboard),
              const SizedBox(height: 16),
              DashboardNextCard(dashboardItem: dashboard),
            ],
          ),
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
            const Text(
              "Gelecek Dönem",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Varlıklar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Varlıklar",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Kasa",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.totalCashAccountBalance,
                        isAsset: true,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Çek",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.nextChequeReceiving,
                        isAsset: true,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Senet",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: dashboardItem.nextDeedReceiving,
                        isAsset: true,
                      ),
                      const SizedBox(height: 16),
                      _BankBalanceList(balances: dashboardItem.totalBankAccountBalances),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Borçlar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Borçlar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Borçlar",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.nextCustomerAccountPayment,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Çekler",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.nextChequePayment,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Senetler",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: dashboardItem.nextDeedPayment,
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
            Text(
              "Güncel (${_getCurrentMonthYear()})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Varlıklar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Varlıklar",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Kasa",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.totalCashAccountBalance,
                        isAsset: true,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Çek",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.activeChequeReceiving,
                        isAsset: true,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap  \n Senet",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: dashboardItem.activeDeedReceiving,
                        isAsset: true,
                      ),
                      const SizedBox(height: 16),
                      _BankBalanceList(balances: dashboardItem.totalBankAccountBalances),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Borçlar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Borçlar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Cari Borçlar",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.activeCustomerAccountPayment,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Çekler",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.activeChequePayment,
                      ),
                      const SizedBox(height: 16),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Senetler",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: dashboardItem.activeDeedPayment,
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

class _BankBalanceList extends StatelessWidget {
  final List<BankAccountBalance> balances;

  const _BankBalanceList({required this.balances});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'lib/assets/images/icon_bank.svg',
          width: 32,
          height: 32,
          alignment: Alignment.center,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Banka", overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              if (balances.isEmpty)
                Text(
                  "0,00 ₺", // Default display
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700, // Assets are green by default for 0
                  ),
                )
              else
                ...balances.map((balance) {
                  Color color;
                  if (balance.totalBankAccountBalance > 0) {
                    color = Colors.green.shade700;
                  } else if (balance.totalBankAccountBalance < 0) {
                    color = Colors.red.shade700;
                  } else {
                    color = Colors.green.shade700; // Bank balances are assets, so 0 is green
                  }

                  final formatter = NumberFormat.decimalPattern('tr_TR');

                  String formattedAmount = formatter.format(balance.totalBankAccountBalance.abs());

                  if (balance.currencyCode == "TRY") {
                    formattedAmount = "$formattedAmount ₺";
                  } else {
                    formattedAmount = "$formattedAmount ${balance.currencyCode}";
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      formattedAmount,
                      style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardListItem extends StatelessWidget {
  final String dashboardTitle;
  final String imagePath;
  final double amount;
  final bool isAsset;

  const DashboardListItem({
    super.key,
    required this.dashboardTitle,
    required this.imagePath,
    required this.amount,
    this.isAsset = false, // Default to liability
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    Color color;
    if (amount > 0) {
      color = Colors.green.shade700;
    } else if (amount < 0) {
      color = Colors.red.shade700;
    } else {
      // For 0, color depends on whether it's an asset or liability
      color = isAsset ? Colors.green.shade700 : Colors.red.shade700;
    }

    final formattedAmount = formatter.format(amount.abs());

    return Row(
      children: [
        SvgPicture.asset(
          imagePath,
          width: 32,
          height: 32,
          alignment: Alignment.center,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dashboardTitle, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(
                formattedAmount,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              )
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
