import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/account_models.dart';

class AccountListView extends StatelessWidget {
  final List<AccountModel> accounts;
  final bool isLoading;
  final ScrollController scrollController;
  final NumberFormat defaultCurrencyFormatter;

  const AccountListView({
    Key? key,
    required this.accounts,
    required this.isLoading,
    required this.scrollController,
    required this.defaultCurrencyFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && accounts.isEmpty) {
      return const Center(child: AppLoadingIndicator());
    }

    if (accounts.isEmpty && !isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * AppConstants.screenHeightMultiplierHalf,
        child: Center(
          child: Text(
            'Hiç hesap bulunamadı.',
            style: TextStyle(color: AppTheme.gray600),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: accounts.length + (isLoading && accounts.isNotEmpty ? 1 : 0),
      itemBuilder: (ctx, idx) {
        if (idx < accounts.length) {
          final account = accounts[idx];
          // Use a specific formatter for the item if currency codes can vary
          final itemCurrencyFormatter = NumberFormat.currency(
            locale: 'tr_TR',
            // Or a locale appropriate for the currencyCode
            decimalDigits: 2,
            // Determine symbol based on currencyCode, fallback to currencyCode itself or default
            symbol:
            account.currencyCode == "TRY"
                ? "₺"
                : (account.currencyCode == "USD"
                ? "\$"
                : (account.currencyCode == "EUR"
                ? "€"
                : account.currencyCode)),
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingS),
            elevation: AppConstants.elevationLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
            ),
            child: ListTile(
              title: Text(
                account.accountName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tür: ${account.accountType}'),
                  Row(
                    children: [
                      Text(
                        itemCurrencyFormatter.format(account.balance.abs()),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeL,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingXs),
                      if (account.balance < 0)
                        const Text(
                          "(B)",
                          style: TextStyle(
                            color: AppTheme.buttonSuccessColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeL,
                          ),
                        )
                      else if (account.balance > 0)
                        const Text(
                          "(A)",
                          style: TextStyle(
                            color: AppTheme.buttonErrorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeL,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // onTap: () {
              //   Navigate to an Account Detail Page if needed
              //    context.push('/accountDetail', extra: account.accountId);
              // },
            ),
          );
        }
        if (isLoading && accounts.isNotEmpty) {
          // Loading indicator at the bottom for pagination
          return const Padding(
            padding: EdgeInsets.all(AppConstants.spacingM),
            child: Center(child: AppLoadingIndicator()),
          );
        }
        return const SizedBox.shrink(); // Should not be reached if itemCount is correct
      },
    );
  }
}