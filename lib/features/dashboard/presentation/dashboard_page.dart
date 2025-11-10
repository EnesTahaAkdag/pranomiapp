import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';
import 'package:pranomiapp/core/utils/formatters.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/features/dashboard/data/dashboard_model.dart';
import 'package:pranomiapp/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.isLoading && viewModel.dashboardItem == null) {
      return const Center(
        child: AppLoadingIndicator(),
      );
    }

    if (viewModel.error != null && viewModel.dashboardItem == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              ElevatedButton(
                onPressed: () => viewModel.fetchDashboard(),
                child: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      );
    }

    final DashboardItem dashboard =
        viewModel.dashboardItem ??
        // Provide a default empty item to prevent null issues in UI
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

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchDashboard(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            DashboardCard(dashboardTitle: "Güncel", dashboardItem: dashboard),
            const SizedBox(height: AppConstants.spacingM),
            DashboardNextCard(dashboardItem: dashboard),
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
    return Card(
      elevation: AppConstants.elevationMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusM)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Gelecek Dönem",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeL),
            ),
            const SizedBox(height: AppConstants.spacingM),
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
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Kasa",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.totalCashAccountBalance,
                        isAsset: true,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap Çek",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.nextChequeReceiving,
                        isAsset: true,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap Senet",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: dashboardItem.nextDeedReceiving,
                        isAsset: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingL),
                // Borçlar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Borçlar",
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Cari Borçlar",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.nextCustomerAccountPayment,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Çekler",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.nextChequePayment,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
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
            const SizedBox(height: AppConstants.spacingM),
            _BankBalanceList(balances: dashboardItem.totalBankAccountBalances),
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
      elevation: AppConstants.elevationMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusM)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Güncel (${_getCurrentMonthYear()})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeL),
            ),
            const SizedBox(height: AppConstants.spacingM),
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
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Kasa",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.totalCashAccountBalance,
                        isAsset: true,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap Çek",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.activeChequeReceiving,
                        isAsset: true,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Cari Hesap Senet",
                        imagePath: 'lib/assets/images/icon_bond.svg',
                        amount: dashboardItem.activeDeedReceiving,
                        isAsset: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingL),
                // Borçlar sütunu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Borçlar",
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Cari Borçlar",
                        imagePath: 'lib/assets/images/icon_cash_account.svg',
                        amount: dashboardItem.activeCustomerAccountPayment,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      DashboardListItem(
                        dashboardTitle: "Ödenecek Çekler",
                        imagePath: 'lib/assets/images/icon_cheque.svg',
                        amount: dashboardItem.activeChequePayment,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
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
            const SizedBox(height: AppConstants.spacingM),
            _BankBalanceList(balances: dashboardItem.totalBankAccountBalances),
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
    // Separate TRY from other currencies
    BankAccountBalance? tryBalance;
    final otherBalances = <BankAccountBalance>[];

    for (final balance in balances) {
      if (balance.currencyCode == 'TRY') {
        tryBalance = balance;
      } else {
        otherBalances.add(balance);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'lib/assets/images/icon_bank.svg',
          width: AppConstants.iconSizeL,
          height: AppConstants.iconSizeL,
          alignment: Alignment.center,
          colorFilter: ColorFilter.mode(
            AppTheme.orange,
            BlendMode.srcIn, // Tüm SVG'yi tek renge boyar
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Banka", overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppConstants.spacingS),
              if (balances.isEmpty)
                const Text(
                  "0,00 ₺",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                    fontSize: AppConstants.fontSizeS,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TRY on its own line
                    if (tryBalance != null) _buildBalanceText(tryBalance),
                    // Other currencies in a row
                    if (otherBalances.isNotEmpty) ...[
                      if (tryBalance != null) const SizedBox(height: AppConstants.spacingXs),
                      Wrap(
                        spacing: AppConstants.spacingS,
                        runSpacing: AppConstants.spacingXs,
                        children: [
                          for (final balance in otherBalances)
                            _buildBalanceText(balance),
                        ],
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceText(BankAccountBalance balance) {
    Color color;
    if (balance.totalBankAccountBalance > 0) {
      color = AppTheme.successColor;
    } else if (balance.totalBankAccountBalance < 0) {
      color = AppTheme.errorColor;
    } else {
      color = AppTheme.successColor;
    }

    String formattedAmount = AppFormatters.decimal.format(
      balance.totalBankAccountBalance.abs(),
    );

    final currencySymbol = _convertCurrencyCodesToSymbols(balance.currencyCode);

    if (currencySymbol == "₺") {
      formattedAmount = "$formattedAmount ₺";
    } else {
      formattedAmount = "$formattedAmount $currencySymbol";
    }

    return Text(
      formattedAmount,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: AppConstants.fontSizeS,
      ).copyWith(color: color),
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
    Color color;
    if (amount > 0) {
      color = AppTheme.successColor;
    } else if (amount < 0) {
      color = AppTheme.errorColor;
    } else {
      // For 0, color depends on whether it's an asset or liability
      color = isAsset ? AppTheme.successColor : AppTheme.errorColor;
    }

    final formattedAmount = AppFormatters.currencyWithSymbol.format(amount.abs());

    return Row(
      children: [
        SvgPicture.asset(
          imagePath,
          width: AppConstants.iconSizeL,
          height: AppConstants.iconSizeL,
          alignment: Alignment.center,
          colorFilter: const ColorFilter.mode(
            AppTheme.orange,
            BlendMode.srcIn, // Tüm SVG'yi tek renge boyar
          ),

        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dashboardTitle, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                formattedAmount,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: AppConstants.fontSizeS,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _getCurrentMonthYear() {
  return AppFormatters.monthYear.format(DateTime.now());
}

String _convertCurrencyCodesToSymbols(String currencyCode) {
  switch (currencyCode) {
    case "TRY":
      return "₺";
    case "EUR":
      return "€";
    case "USD":
      return "\$";
    default:
      return currencyCode;
  }
}
