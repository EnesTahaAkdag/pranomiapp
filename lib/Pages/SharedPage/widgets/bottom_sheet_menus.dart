import 'package:flutter/material.dart';

class BottomSheetMenus {
  static Future<void> showIncomeSubMenu(
      BuildContext context,
      String currentRoute,
      Function(String) onNavigate,
      ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildListTile(context, "Alınan Siparişler", '/incomeorder', currentRoute, onNavigate),
            _buildListTile(context, "Satış Faturası", '/incomeinvoice', currentRoute, onNavigate),
            _buildListTile(context, "Satış İade Faturası", '/incomeclaim', currentRoute, onNavigate),
          ],
        );
      },
    );
  }

  static Future<void> showExpenseSubMenu(
      BuildContext context,
      String currentRoute,
      Function(String) onNavigate,
      ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildListTile(context, "Verilen Siparişler", '/expenseorder', currentRoute, onNavigate),
            _buildListTile(context, "Alış Faturası", '/expenseinvoice', currentRoute, onNavigate),
            _buildListTile(context, "Alış İade Faturası", '/expenseclaim', currentRoute, onNavigate),
          ],
        );
      },
    );
  }

  static Future<void> showEDocumentsSubMenu(
      BuildContext context,
      String currentRoute,
      Function(String) onNavigate,
      ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2c2c2c),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white,
                ),
                child: ExpansionTile(
                  title: const Text("Giden", style: TextStyle(color: Colors.white)),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    _buildListTile(context, "E-Faturalar", '/OutGoingE-Invoice', currentRoute, onNavigate),
                    _buildListTile(context, "E-Arşiv Faturalar", '/OutGoingE-Archive', currentRoute, onNavigate),
                    _buildListTile(context, "E-İrsaliyeler", '/OutGoingE-Dispatch', currentRoute, onNavigate),
                  ],
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  unselectedWidgetColor: Colors.white,
                ),
                child: ExpansionTile(
                  title: const Text("Gelen", style: TextStyle(color: Colors.white)),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    _buildListTile(context, "E-Faturalar", '/ApprovedE-Invoice', currentRoute, onNavigate),
                    _buildListTile(context, "E-İrsaliyeler", '/ApprovedE-Dispatch', currentRoute, onNavigate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildListTile(
      BuildContext context,
      String title,
      String route,
      String currentRoute,
      Function(String) onNavigate,
      ) {
    final bool isSelected = currentRoute == route;

    return Container(
      color: isSelected ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        leading: const Icon(Icons.arrow_right, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          onNavigate(route);
        },
      ),
    );
  }
}