// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Home screen with inventory list, stats and filters.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Friday, 17-Jul-2026
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth.dart';
import '../../bloc/categories/categories.dart';
import '../../bloc/inventory/inventory.dart';
import '../../core/constants/api_constants.dart';
import '../../models/categories/categories.dart';
import '../../models/inventory/inventory.dart';
import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    context.read<CategoriesBloc>().add(const CategoriesLoadRequested());

    context.read<InventoryBloc>().add(const InventoryLoadRequested());
  }

  Future<void> _refreshInventory() async {
    context.read<CategoriesBloc>().add(const CategoriesLoadRequested());
    context.read<InventoryBloc>().add(const InventoryLoadRequested());
  }

  void _changeExpiryFilter(String? expiryState) {
    final currentState = context.read<InventoryBloc>().state;

    String? selectedCategoryId;

    if (currentState is InventoryLoadSuccess) {
      selectedCategoryId = currentState.selectedCategoryId;
    } else if (currentState is InventoryActionInProgress) {
      selectedCategoryId = currentState.selectedCategoryId;
    }

    context.read<InventoryBloc>().add(
      InventoryFilterChanged(
        categoryId: selectedCategoryId,
        expiryState: expiryState,
      ),
    );
  }

  void _changeCategoryFilter(String? categoryId) {
    final currentState = context.read<InventoryBloc>().state;

    String? selectedExpiryState;

    if (currentState is InventoryLoadSuccess) {
      selectedExpiryState = currentState.selectedExpiryState;
    } else if (currentState is InventoryActionInProgress) {
      selectedExpiryState = currentState.selectedExpiryState;
    }

    context.read<InventoryBloc>().add(
      InventoryFilterChanged(
        categoryId: categoryId,
        expiryState: selectedExpiryState,
      ),
    );
  }

  List<InventoryItemModel> _applySearch(List<InventoryItemModel> items) {
    if (_searchQuery.trim().isEmpty) {
      return items;
    }

    final query = _searchQuery.trim().toLowerCase();

    return items.where((item) {
      return item.displayName.toLowerCase().contains(query) ||
          item.categoryName.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoadInProgress) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (state is InventoryFailure) {
              return _ErrorView(
                message: state.message,
                onRetry: _refreshInventory,
              );
            }

            if (state is InventoryLoadSuccess) {
              return _HomeContent(
                items: _applySearch(state.items),
                stats: state.stats,
                selectedCategoryId: state.selectedCategoryId,
                selectedExpiryState: state.selectedExpiryState,
                isActionInProgress: false,
                searchQuery: _searchQuery,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onRefresh: _refreshInventory,
                onCategoryChanged: _changeCategoryFilter,
                onExpiryChanged: _changeExpiryFilter,
              );
            }

            if (state is InventoryActionInProgress) {
              return _HomeContent(
                items: _applySearch(state.items),
                stats: state.stats,
                selectedCategoryId: state.selectedCategoryId,
                selectedExpiryState: state.selectedExpiryState,
                isActionInProgress: true,
                searchQuery: _searchQuery,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onRefresh: _refreshInventory,
                onCategoryChanged: _changeCategoryFilter,
                onExpiryChanged: _changeExpiryFilter,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<InventoryItemModel> items;
  final InventoryStatsModel stats;
  final String? selectedCategoryId;
  final String? selectedExpiryState;
  final bool isActionInProgress;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onExpiryChanged;

  const _HomeContent({
    required this.items,
    required this.stats,
    required this.selectedCategoryId,
    required this.selectedExpiryState,
    required this.isActionInProgress,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onCategoryChanged,
    required this.onExpiryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.card,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String userName = 'User';

              if (authState is AuthAuthenticated) {
                userName = authState.user.name;
              } else if (authState is AuthActionInProgress) {
                userName = authState.user.name;
              }

              return _WelcomeHeader(userName: userName);
            },
          ),
          const SizedBox(height: 26),
          _SectionTitle(
            title: 'Analytics',
            actionText: 'see more',
            onActionTap: () {},
          ),
          const SizedBox(height: 12),
          _AnalyticsGrid(stats: stats),
          const SizedBox(height: 26),
          const _SimpleSectionTitle(title: 'Select Category'),
          const SizedBox(height: 14),
          _CategorySelector(
            selectedCategoryId: selectedCategoryId,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 14),
          _ExpiryFilterRow(
            selectedExpiryState: selectedExpiryState,
            onChanged: onExpiryChanged,
          ),
          const SizedBox(height: 18),
          _SearchField(value: searchQuery, onChanged: onSearchChanged),
          const SizedBox(height: 22),
          if (items.isEmpty)
            const _EmptyInventoryCard()
          else
            for (final item in items) ...[
              _InventoryCard(item: item),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String userName;

  const _WelcomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final displayName = userName.trim().isEmpty ? 'User' : userName.trim();

    return Center(
      child: Text(
        'Welcome back, $displayName!',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

class _SimpleSectionTitle extends StatelessWidget {
  final String title;

  const _SimpleSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      title,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  const _SectionTitle({
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsGrid extends StatelessWidget {
  final InventoryStatsModel stats;

  const _AnalyticsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AnalyticsCard(
                value: stats.expiredCount,
                label: 'Expired',
                icon: Icons.close,
                fillColor: colors.dangerSoft,
                borderColor: colors.dangerBorder,
                valueColor: colors.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnalyticsCard(
                value: stats.expiringTomorrowCount,
                label: 'Expires tomorrow',
                icon: Icons.warning_rounded,
                fillColor: colors.warningSoft,
                borderColor: colors.warningBorder,
                valueColor: colors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnalyticsCard(
                value: stats.expiringInFiveDaysCount,
                label: 'Expires in 5 days',
                icon: Icons.schedule,
                fillColor: colors.warningSoft,
                borderColor: colors.warningBorder,
                valueColor: colors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnalyticsCard(
                value: stats.freshCount,
                label: 'Fresh',
                icon: Icons.check_circle,
                fillColor: colors.successSoft,
                borderColor: colors.successBorder,
                valueColor: colors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color fillColor;
  final Color borderColor;
  final Color valueColor;

  const _AnalyticsCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.fillColor,
    required this.borderColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: valueColor.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategorySelector({
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading || state is CategoriesInitial) {
          return SizedBox(
            height: 86,
            child: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        if (state is CategoriesFailure) {
          return SizedBox(
            height: 86,
            child: Center(
              child: Text(
                state.message,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        if (state is! CategoriesLoaded) {
          return const SizedBox.shrink();
        }

        final categories = state.categories;

        return SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryId == category.id;

              return _CategoryCircle(
                category: category,
                isSelected: isSelected,
                onTap: () => onChanged(isSelected ? null : category.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCircle({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final iconUrl = category.iconUrl;

    return SizedBox(
      width: 58,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isSelected ? colors.chipSelected : colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colors.chipSelectedBorder : colors.border,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: iconUrl == null || iconUrl.isEmpty
                  ? Icon(
                      _iconForCategory(category.key),
                      size: 28,
                      color: isSelected ? colors.primary : colors.textSecondary,
                    )
                  : AppCachedNetworkImage(
                      imageUrl: iconUrl,
                      fallback: Icon(
                        _iconForCategory(category.key),
                        size: 28,
                        color: isSelected
                            ? colors.primary
                            : colors.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryFilterRow extends StatelessWidget {
  final String? selectedExpiryState;
  final ValueChanged<String?> onChanged;

  const _ExpiryFilterRow({
    required this.selectedExpiryState,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallPill(
          label: 'All',
          isSelected: selectedExpiryState == null,
          onTap: () => onChanged(null),
        ),
        const SizedBox(width: 8),
        _SmallPill(
          label: 'Fresh',
          isSelected: selectedExpiryState == 'fresh',
          onTap: () => onChanged('fresh'),
        ),
        const SizedBox(width: 8),
        _SmallPill(
          label: 'Expiring',
          isSelected: selectedExpiryState == 'expiring',
          onTap: () => onChanged('expiring'),
        ),
        const SizedBox(width: 8),
        _SmallPill(
          label: 'Expired',
          isSelected: selectedExpiryState == 'expired',
          onTap: () => onChanged('expired'),
        ),
      ],
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SmallPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.chipSelected : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.chipSelectedBorder : colors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isSelected ? colors.primary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(
          fontSize: 13,
          color: colors.textMuted,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(Icons.search, size: 20, color: colors.primary),
        filled: true,
        fillColor: colors.card,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItemModel item;

  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final expiryColors = _colorsForExpiryState(
      context: context,
      expiryState: item.expiryState,
    );
    final imageUrl = _bestImageUrlForItem(item) ?? item.categoryIconUrl;

    return InkWell(
      onTap: () {
        context.router.push(InventoryItemDetailsRoute(item: item));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: expiryColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: expiryColors.fill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: expiryColors.border),
              ),
              child: imageUrl == null
                  ? Icon(
                      _iconForCategory(item.categoryKey),
                      color: expiryColors.foreground,
                      size: 28,
                    )
                  : AppCachedNetworkImage(
                      imageUrl: imageUrl,
                      fallback: Icon(
                        _iconForCategory(item.categoryKey),
                        color: expiryColors.foreground,
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(color: colors.textSecondary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatAmount(item.amount, item.unit),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatLocation(item.location),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Added ${_formatDate(item.addedAt)}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ExpiryStatus(expiryState: item.expiryState),
          ],
        ),
      ),
    );
  }
}

class _ExpiryStatus extends StatelessWidget {
  final String expiryState;

  const _ExpiryStatus({required this.expiryState});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForExpiryState(
      context: context,
      expiryState: expiryState,
    );

    return Column(
      children: [
        Icon(
          expiryState == 'expired'
              ? Icons.warning_rounded
              : expiryState == 'expiring'
              ? Icons.schedule
              : Icons.check_circle,
          size: 18,
          color: colors.foreground,
        ),
        const SizedBox(height: 2),
        Text(
          _formatExpiryState(expiryState),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: colors.foreground,
          ),
        ),
      ],
    );
  }
}

class _EmptyInventoryCard extends StatelessWidget {
  const _EmptyInventoryCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 46, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            'No food items yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan or add your first product to start tracking expiration dates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.primary),
            const SizedBox(height: 14),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _ExpiryColors {
  final Color fill;
  final Color border;
  final Color foreground;

  const _ExpiryColors({
    required this.fill,
    required this.border,
    required this.foreground,
  });
}

_ExpiryColors _colorsForExpiryState({
  required BuildContext context,
  required String expiryState,
}) {
  final colors = context.appColors;

  switch (expiryState) {
    case 'expired':
      return _ExpiryColors(
        fill: colors.dangerSoft,
        border: colors.dangerBorder,
        foreground: colors.danger,
      );
    case 'expiring':
      return _ExpiryColors(
        fill: colors.warningSoft,
        border: colors.warningBorder,
        foreground: colors.warning,
      );
    case 'fresh':
    default:
      return _ExpiryColors(
        fill: colors.successSoft,
        border: colors.successBorder,
        foreground: colors.success,
      );
  }
}

IconData _iconForCategory(String category) {
  switch (category) {
    case 'dairy':
      return Icons.local_drink_outlined;
    case 'meat':
      return Icons.set_meal_outlined;
    case 'seafood':
      return Icons.phishing_outlined;
    case 'fruits':
      return Icons.apple_outlined;
    case 'vegetables':
      return Icons.eco_outlined;
    case 'bakery':
      return Icons.bakery_dining_outlined;
    case 'grains':
      return Icons.rice_bowl_outlined;
    case 'beverages':
      return Icons.local_cafe_outlined;
    case 'snacks':
      return Icons.fastfood_outlined;
    case 'frozen':
      return Icons.ac_unit_outlined;
    case 'canned':
      return Icons.inventory_2_outlined;
    case 'cooked_food':
      return Icons.restaurant_outlined;
    case 'leftovers':
      return Icons.takeout_dining_outlined;
    case 'condiments':
      return Icons.soup_kitchen_outlined;
    case 'other':
    default:
      return Icons.dinner_dining_outlined;
  }
}

String _formatAmount(double amount, String unit) {
  final amountText = amount % 1 == 0
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(1);

  return '$amountText$unit';
}

String _formatLocation(String location) {
  if (location.isEmpty) return location;

  return location[0].toUpperCase() + location.substring(1);
}

String _formatExpiryState(String expiryState) {
  switch (expiryState) {
    case 'expired':
      return 'Expired';
    case 'expiring':
      return 'Expiring';
    case 'fresh':
    default:
      return 'Fresh';
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String? _bestImageUrlForItem(InventoryItemModel item) {
  if (item.itemImageUrl != null && item.itemImageUrl!.isNotEmpty) {
    return ApiConstants.resolveImageUrl(item.itemImageUrl);
  }

  if (item.productImageUrl != null && item.productImageUrl!.isNotEmpty) {
    return ApiConstants.resolveImageUrl(item.productImageUrl);
  }

  return null;
}
