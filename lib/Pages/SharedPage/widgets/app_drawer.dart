import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'drawer_menu_item.dart';
import 'drawer_expandable_tile.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final String? openMenuId;
  final bool showIncomeExpense;
  final bool showEDocuments;
  final Function(String) onNavigate;
  final Function(String) onToggleMenu;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.openMenuId,
    required this.showIncomeExpense,
    required this.showEDocuments,
    required this.onNavigate,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF3F3F3F),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              children: _buildMenuItems(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 30),
      width: double.infinity,
      color: const Color(0xFFB00034),
      child: Center(
        child: Image.asset(
          'lib/assets/images/PranomiLogo.png',
          height: 90,
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    return [
      DrawerExpandableTile(
        imagePath: "icon_tachometer.svg",
        title: "Güncel Durum",
        id: "Current",
        isExpanded: openMenuId == "Current",
        onToggle: onToggleMenu,
        children: [
          DrawerMenuItem(
            imagePath: "icon_signature.svg",
            title: "Genel Bakış",
            route: '/',
            currentRoute: currentRoute,
            onTap: onNavigate,
          ),
        ],
      ),
      DrawerExpandableTile(
        imagePath: "icon_archieve.svg",
        title: "Stok",
        id: "stock",
        isExpanded: openMenuId == "stock",
        onToggle: onToggleMenu,
        children: [
          DrawerMenuItem(
            imagePath: "icon_cubes.svg",
            title: "Ürünler ve Hizmetler",
            route: '/ProductsandServices',
            currentRoute: currentRoute,
            onTap: onNavigate,
          ),
          DrawerMenuItem(
            imagePath: "icon_briefcase.svg",
            title: "Masraflar",
            route: '/zsdxcf',
            currentRoute: currentRoute,
            onTap: onNavigate,
          ),
          DrawerMenuItem(
            imagePath: "icon_file_invoice.svg",
            title: "Gelir İrsaliyeleri",
            route: '/IncomeWayBill',
            currentRoute: currentRoute,
            onTap: onNavigate,
          ),
          DrawerMenuItem(
            imagePath: "icon_file_lines.svg",
            title: "Gider İrsaliyeleri",
            route: '/ExpenseWayBill',
            currentRoute: currentRoute,
            onTap: onNavigate,
          ),
        ],
      ),
      DrawerMenuItem(
        imagePath: "icon_users.svg",
        title: "Cari Hesaplar",
        route: '/CustomerAccounts',
        currentRoute: currentRoute,
        onTap: onNavigate,
      ),
      DrawerMenuItem(
        imagePath: "icon_usertie.svg",
        title: "Çalışanlar",
        route: '/EmployeAccounts',
        currentRoute: currentRoute,
        onTap: onNavigate,
      ),
      if (showIncomeExpense)
        DrawerExpandableTile(
          imagePath: "icon_caret_square_down.svg",
          title: "Gelirler",
          id: "income",
          isExpanded: openMenuId == "income",
          onToggle: onToggleMenu,
          children: [
            DrawerMenuItem(
              imagePath: "icon_file_contract.svg",
              title: "Alınan Siparişler",
              route: '/InComeOrder',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
            DrawerMenuItem(
              imagePath: "icon_file_download.svg",
              title: "Satış Faturası",
              route: '/InComeInvoice',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
            DrawerMenuItem(
              imagePath: "icon_file_upload.svg",
              title: "Satış İade Faturası",
              route: '/InComeClaim',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
          ],
        ),
      if (showIncomeExpense)
        DrawerExpandableTile(
          imagePath: "icon_caret_square_up.svg",
          title: "Giderler",
          id: "u",
          isExpanded: openMenuId == "u",
          onToggle: onToggleMenu,
          children: [
            DrawerMenuItem(
              imagePath: "icon_file_contract.svg",
              title: "Verilen Siparişler",
              route: '/ExpenseOrder',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
            DrawerMenuItem(
              imagePath: "icon_file_download.svg",
              title: "Alış Faturası",
              route: '/ExpenseInvoice',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
            DrawerMenuItem(
              imagePath: "icon_file_upload.svg",
              title: "Alış İade Faturası",
              route: '/ExpenseClaim',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
          ],
        ),
      if (showEDocuments)
        DrawerExpandableTile(
          imagePath: "icon_note_sticky.svg",
          title: "E-Belgeler",
          id: "ğ",
          isExpanded: openMenuId == "ğ",
          onToggle: onToggleMenu,
          children: [
            DrawerExpandableTile(
              imagePath: "icon_arrow_up.svg",
              title: "Giden",
              id: "edoc_out",
              isExpanded: openMenuId == "edoc_out",
              onToggle: onToggleMenu,
              children: [
                DrawerMenuItem(
                  imagePath: "icon_file_invoice.svg",
                  title: "E-Faturalar",
                  route: '/OutGoingE-Invoice',
                  currentRoute: currentRoute,
                  onTap: onNavigate,
                ),
                DrawerMenuItem(
                  imagePath: "icon_file_contract.svg",
                  title: "E-Arşiv Faturalar",
                  route: '/OutGoingE-Archive',
                  currentRoute: currentRoute,
                  onTap: onNavigate,
                ),
                DrawerMenuItem(
                  imagePath: "icon_file_lines.svg",
                  title: "E-İrsaliyeler",
                  route: '/OutGoingE-Dispatch',
                  currentRoute: currentRoute,
                  onTap: onNavigate,
                ),
              ],
            ),
            DrawerExpandableTile(
              imagePath: "icon_arrow_down.svg",
              title: "Gelen",
              id: "g",
              isExpanded: openMenuId == "g",
              onToggle: onToggleMenu,
              children: [
                DrawerMenuItem(
                  imagePath: "icon_file_invoice.svg",
                  title: "E-Faturalar",
                  route: '/ApprovedE-Invoice',
                  currentRoute: currentRoute,
                  onTap: onNavigate,
                ),
                DrawerMenuItem(
                  imagePath: "icon_file_lines.svg",
                  title: "E-İrsaliyeler",
                  route: '/ApprovedE-Dispatch',
                  currentRoute: currentRoute,
                  onTap: onNavigate,
                ),
              ],
            ),
          ],
        ),
      if (showIncomeExpense)
        DrawerExpandableTile(
          imagePath: "icon_money.svg",
          title: "Nakit",
          id: "f",
          isExpanded: openMenuId == "f",
          onToggle: onToggleMenu,
          children: [
            DrawerMenuItem(
              imagePath: "icon_building.svg",
              title: "Kasa ve Bankalar",
              route: '/DepositAndBanks',
              currentRoute: currentRoute,
              onTap: onNavigate,
            ),
          ],
        ),
      DrawerMenuItem(
        imagePath: "icon_lira.svg",
        title: "Kontör",
        route: '/Credits',
        currentRoute: currentRoute,
        onTap: onNavigate,
      ),
      DrawerMenuItem(
        imagePath: "icon_bell.svg",
        title: "Bildirimler",
        route: '/Notifications',
        currentRoute: currentRoute,
        onTap: onNavigate,
      ),
      DrawerMenuItem(
        imagePath: "icon_bullhorn.svg",
        title: "Duyurularım",
        route: '/Announcements',
        currentRoute: currentRoute,
        onTap: onNavigate,
      ),
      DrawerMenuItem(
        imagePath: "icon_logout.svg",
        title: "Çıkış Yap",
        route: '/login',
        currentRoute: currentRoute,
        onTap: onNavigate,
      ),
    ];
  }
}