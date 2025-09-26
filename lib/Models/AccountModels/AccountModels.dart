class AccountResponseModel {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<AccountModel> accounts;

  AccountResponseModel({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.accounts,
  });
  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountResponseModel(
      count: json['Count'],
      currentPage: json['CurrentPage'],
      currentSize: json['CurrentSize'],
      totalPages: json['TotalPages'],
      accounts:
          (json['Customers'] as List)
              .map((account) => AccountModel.fromJson(account))
              .toList() ?? [],
    );
  }
}

class AccountModel {
  final int accountId;
  final String accountName;
  final String accountType;
  final double balance;
  final String currencyCode;

  AccountModel({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.balance,
    required this.currencyCode,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['AccountId'],
      accountName: json['AccountName'],
      accountType: json['AccountType'],
      balance: json['Balance'].toDouble(),
      currencyCode: json['CurrencyCode'],
    );
  }
}
