import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  void _openAddOptions(BuildContext context) {
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: _AddOptionButton(
                    icon: Icons.edit_note,
                    title: 'Add manually',
                    onTap: () {
                      Navigator.of(context).pop();

                      context.router.push(AddManualProductRoute());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddOptionButton(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan barcode',
                    onTap: () {
                      Navigator.of(context).pop();

                      context.router.push(const ScannerRoute());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        ShoppingRoute(),
        RecipesRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          extendBody: true,
          body: child,
          floatingActionButton: FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: () => _openAddOptions(context),
            backgroundColor: colors.primary,
            foregroundColor: colors.textOnPrimary,
            elevation: 8,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: colors.card,
            elevation: 12,
            shadowColor: colors.shadow,
            surfaceTintColor: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: tabsRouter.setActiveIndex,
                  ),
                  _NavItem(
                    icon: Icons.shopping_cart_outlined,
                    selectedIcon: Icons.shopping_cart,
                    label: 'Shopping',
                    index: 1,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: tabsRouter.setActiveIndex,
                  ),
                  const SizedBox(width: 48),
                  _NavItem(
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    label: 'Recipes',
                    index: 2,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: tabsRouter.setActiveIndex,
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: tabsRouter.setActiveIndex,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isSelected = index == activeIndex;
    final itemColor = isSelected ? colors.primary : colors.textMuted;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: itemColor, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: itemColor,
                fontSize: 10,
                height: 1,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AddOptionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
