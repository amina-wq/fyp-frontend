import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  void _openScanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanner will be added later'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          body: child,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openScanner(context),
            backgroundColor: AppColors.bottomNavigationBar,
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 72,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bottomNavigationBar,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
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
    final isSelected = index == activeIndex;
    final color = isSelected ? Colors.white : Colors.white70;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}