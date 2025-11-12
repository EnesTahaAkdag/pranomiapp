import 'package:flutter/material.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/theme_service.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';
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
    final themeService = locator<ThemeService>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Drawer(
      backgroundColor: AppTheme.darkGrayBackground,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: bottomPadding + AppConstants.spacingM),
              children: [..._buildMenuItems(),_buildThemeSwitch(context, themeService),]


            ),

          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: AppConstants.headerPaddingTop, bottom: AppConstants.headerPaddingBottom),
      width: double.infinity,
      color: AppTheme.accentColor,
      child: Center(
        child: Image.asset(
          'lib/assets/images/PranomiLogo10.png',
          height: AppConstants.logoHeight,
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

  Widget _buildThemeSwitch(BuildContext context, ThemeService themeService) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDarkMode(context);

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingM,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                themeService.toggleTheme();
              },
              child: Container(
                width: 84,
                height: 42,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  // Ana arka plan - mod durumuna göre
                  color: isDark
                      ? const Color(0xFF1e293b) // Slate gray - dark mode
                      : const Color(0xFFfef3c7), // Amber light - light mode
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFfbbf24),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : const Color(0xFFfbbf24).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Arka plan ikonları
                    Row(
                      children: [
                        // Sol - Güneş ikonu
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              color: isDark
                                  ? const Color(0xFF475569) // Loş görünür
                                  : const Color(0xFFf59e0b), // Parlak sarı
                              size: 20,
                            ),
                          ),
                        ),
                        // Sağ - Ay ikonu
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.nightlight_round,
                              color: isDark
                                  ? const Color(0xFF818cf8) // Parlak mor
                                  : const Color(0xFF94a3b8), // Loş görünür
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Kaydırılan thumb button
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      alignment: isDark
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 38,
                        height: 34,
                        decoration: BoxDecoration(
                          // Thumb rengi - aktif moda göre
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                              const Color(0xFF6366f1), // Indigo
                              const Color(0xFF4f46e5),
                            ]
                                : [
                              const Color(0xFFfbbf24), // Amber
                              const Color(0xFFf59e0b),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFF4f46e5).withValues(alpha: 0.6)
                                  : const Color(0xFFf59e0b).withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                            // İç gölge efekti
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: RotationTransition(
                                  turns: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              isDark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_rounded,
                              key: ValueKey(isDark),
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
