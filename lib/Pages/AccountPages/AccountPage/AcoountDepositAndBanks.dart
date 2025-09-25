import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/AccountModels/AccountModels.dart';
import 'package:pranomiapp/services/AccountServers/AccountService.dart';

import '../../../core/di/Injection.dart';

class AccountDepositAndBanksPage extends StatefulWidget {
  const AccountDepositAndBanksPage({super.key});

  @override
  State<AccountDepositAndBanksPage> createState() =>
      _AccountDepositAndBanksPageState();
}

class _AccountDepositAndBanksPageState
    extends State<AccountDepositAndBanksPage> {
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;
  String _searchText = '';
  final List<AccountModel> _accounts = [];


  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final _accountService = locator<AccountService>();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
