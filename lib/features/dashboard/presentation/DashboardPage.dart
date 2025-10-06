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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:
          _dashboardItem != null
              ? DashboardCard(
                dashboardTitle: "Güncel",
                dashboardItem: _dashboardItem!,
              )
              : DashboardCard(
                dashboardTitle: "Güncel",
                dashboardItem: DashboardItem(
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
                ),
              ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchDashboard,
                child: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      );
    }
    if (_dashboardItem == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Gösterilecek veri bulunamadı."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchDashboard,
              child: const Text("Yenile"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDashboard,
      child: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildCashAndBankCard(_dashboardItem!),
          const SizedBox(height: 12),
          _buildCustomerAccountCard(_dashboardItem!),
          const SizedBox(height: 12),
          _buildTotalIncomeExpenseCard(_dashboardItem!),
          const SizedBox(height: 12),
          _buildInvoiceCard(
            'Fatura',
            _dashboardItem!.activeInvoiceReceiving,
            _dashboardItem!.nextInvoiceReceiving,
            _dashboardItem!.activeInvoicePayment,
            _dashboardItem!.nextInvoicePayment,
          ),
          const SizedBox(height: 12),
          _buildInvoiceCard(
            'Çek',
            _dashboardItem!.activeChequeReceiving,
            _dashboardItem!.nextChequeReceiving,
            _dashboardItem!.activeChequePayment,
            _dashboardItem!.nextChequePayment,
          ),
          const SizedBox(height: 12),
          _buildInvoiceCard(
            'Senet',
            _dashboardItem!.activeDeedReceiving,
            _dashboardItem!.nextDeedReceiving,
            _dashboardItem!.activeDeedPayment,
            _dashboardItem!.nextDeedPayment,
          ),
        ],
      ),
    );
  }

  Widget _buildCashAndBankCard(DashboardItem data) {
    return _DataCard(
      title: 'Kasa ve Banka Bakiyeleri',
      icon: Icons.account_balance_wallet,
      children: [
        _DataRow(
          'Nakit Toplam',
          data.totalCashAccountBalance,
          isReceiving: true,
        ),
        const Divider(),
        ...data.totalBankAccountBalances.map(
          (bank) => _DataRow(
            '${bank.currencyCode} Banka Toplam',
            bank.totalBankAccountBalance,
            isReceiving: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerAccountCard(DashboardItem data) {
    return _DataCard(
      title: 'Cari Hesap Durumu',
      icon: Icons.people,
      children: [
        _DataRow(
          'Vadesi Gelen Alacaklar',
          data.activeCustomerAccountReceiving,
          isReceiving: true,
        ),
        _DataRow('Vadesi Gelen Borçlar', data.activeCustomerAccountPayment),
        const Divider(),
        _DataRow(
          'Gelecek Alacaklar',
          data.nextCustomerAccountReceiving,
          isReceiving: true,
        ),
        _DataRow('Gelecek Borçlar', data.nextCustomerAccountPayment),
      ],
    );
  }

  Widget _buildTotalIncomeExpenseCard(DashboardItem data) {
    return _DataCard(
      title: 'Toplam Gelir ve Gider',
      icon: Icons.swap_horiz,
      children: [
        _DataRow('Toplam Gelir', data.totalIncomeAmount, isReceiving: true),
        _DataRow('Toplam Gider', data.totalExpenseAmount),
      ],
    );
  }

  Widget _buildInvoiceCard(
    String title,
    double activeReceiving,
    double nextReceiving,
    double activePayment,
    double nextPayment,
  ) {
    return _DataCard(
      title: '$title Durumu',
      icon:
          title == 'Fatura'
              ? Icons.receipt_long
              : (title == 'Çek' ? Icons.sticky_note_2 : Icons.description),
      children: [
        _DataRow('Vadesi Gelen Alacaklar', activeReceiving, isReceiving: true),
        _DataRow('Vadesi Gelen Borçlar', activePayment),
        const Divider(),
        _DataRow('Gelecek Alacaklar', nextReceiving, isReceiving: true),
        _DataRow('Gelecek Borçlar', nextPayment),
      ],
    );
  }
}

// Reusable Card Widget
class _DataCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DataCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Reusable Row Widget
class _DataRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isReceiving;

  _DataRow(this.label, this.amount, {this.isReceiving = false});

  final _formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(
            _formatter.format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isReceiving ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          imagePath,
          width: 32,
          height: 32,
          alignment: Alignment.center,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(dashboardTitle), SizedBox(height: 8), Text(amount)],
        ),
      ],
    );
  }
}

String _getCurrentMonthYear() {
  return DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now());
}
