import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth.dart';
import '../../bloc/inventory/inventory.dart';
import '../../models/inventory/inventory.dart';
import '../../bloc/categories/categories.dart';
import '../../models/categories/categories.dart';
import '../../ui/theme/app_colors.dart';
import '../../router/router.dart';
import '../../core/constants/api_constants.dart';
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

    context.read<CategoriesBloc>().add(
      const CategoriesLoadRequested(),
    );

    context.read<InventoryBloc>().add(
      const InventoryLoadRequested(),
    );
  }

  Future<void> _refreshInventory() async {
    context.read<InventoryBloc>().add(
      const InventoryLoadRequested(),
    );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoadInProgress) {
              return const Center(
                child: CircularProgressIndicator(),
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
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String userName = 'User';

              if (authState is AuthAuthenticated) {
                userName = authState.user.name;
              }

              return _WelcomeHeader(
                userName: userName,
              );
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
          const _SimpleSectionTitle(
            title: 'Select Category',
          ),
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
          _SearchField(
            value: searchQuery,
            onChanged: onSearchChanged,
          ),
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

  const _WelcomeHeader({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName.trim().isEmpty ? 'User' : userName.trim();

    return Center(
      child: Text(
        'Welcome back, $displayName!',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1F2147),
        ),
      ),
    );
  }
}

class _SimpleSectionTitle extends StatelessWidget {
  final String title;

  const _SimpleSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Color(0xFF17183B),
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
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF17183B),
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8DB4C6),
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

  const _AnalyticsGrid({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AnalyticsCard(
                value: stats.expiredCount,
                label: 'Expired',
                icon: Icons.close,
                fillColor: AppColors.expiredFill,
                borderColor: AppColors.expiredBorder,
                valueColor: const Color(0xFFD85C5C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnalyticsCard(
                value: stats.expiringTomorrowCount,
                label: 'Expires tomorrow',
                icon: Icons.warning_rounded,
                fillColor: AppColors.expiringTomorrowFill,
                borderColor: AppColors.expiringTomorrowBorder,
                valueColor: const Color(0xFFD99A35),
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
                fillColor: AppColors.expiringInFiveDaysFill,
                borderColor: AppColors.expiringInFiveDaysBorder,
                valueColor: const Color(0xFFD7C934),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnalyticsCard(
                value: stats.freshCount,
                label: 'Fresh',
                icon: Icons.check_circle,
                fillColor: AppColors.freshFill,
                borderColor: AppColors.freshBorder,
                valueColor: const Color(0xFF65D96B),
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
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: valueColor.withValues(alpha: 0.75),
            ),
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
                    color: valueColor.withValues(alpha: 0.65),
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
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading || state is CategoriesInitial) {
          return const SizedBox(
            height: 86,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CategoriesFailure) {
          return SizedBox(
            height: 86,
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
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
                color: isSelected
                    ? AppColors.categoryActiveFill
                    : const Color(0xFFF7F7F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.categoryActiveBorder
                      : const Color(0xFFE2E2E5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: iconUrl == null || iconUrl.isEmpty
                  ? Icon(
                _iconForCategory(category.key),
                size: 28,
                color: const Color(0xFF353535),
              )
                  : AppCachedNetworkImage(
                imageUrl: iconUrl,
                fit: BoxFit.cover,
                fallback: Icon(
                  _iconForCategory(category.key),
                  size: 28,
                  color: const Color(0xFF353535),
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
                color: isSelected
                    ? AppColors.bottomNavigationBar
                    : Colors.black54,
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.categoryActiveFill
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.categoryActiveBorder
                  : const Color(0xFFE4E4E4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppColors.bottomNavigationBar
                  : Colors.black54,
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

  const _SearchField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFFB3B5C0),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: Color(0xFF9CB4C1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFFE7E7EA),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFFE7E7EA),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: AppColors.bottomNavigationBar,
          ),
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItemModel item;

  const _InventoryCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForExpiryState(item.expiryState);
    final imageUrl = _bestImageUrlForItem(item) ?? item.categoryIconUrl;

    return InkWell(
        onTap: () {
          context.router.push(
            InventoryItemDetailsRoute(item: item),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
        height: 94,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
        color: const Color(0xFFF8F5F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
        color: colors.border,
        width: 2,
        ),
      ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.fill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl == null
                  ? Icon(
                  _iconForCategory(item.categoryKey),
                color: const Color(0xFF6BC96A),
                size: 28,
              )
                  : AppCachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fallback: Icon(
                    _iconForCategory(item.categoryKey),
                  color: const Color(0xFF6BC96A),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Color(0xFF52515B),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF55545D),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatAmount(item.amount, item.unit),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatLocation(item.location),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Added ${_formatDate(item.addedAt)}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A8991),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ExpiryStatus(
              expiryState: item.expiryState,
            ),
          ],
        ),
      )
    );
  }
}

class _ExpiryStatus extends StatelessWidget {
  final String expiryState;

  const _ExpiryStatus({
    required this.expiryState,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = expiryState == 'expired';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          isExpired ? Icons.warning_rounded : Icons.check_circle,
          size: 18,
          color: isExpired
              ? const Color(0xFF7ED36D)
              : const Color(0xFF7ED36D),
        ),
        const SizedBox(height: 2),
        Text(
          _formatExpiryState(expiryState),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7ED36D),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 46,
            color: AppColors.bottomNavigationBar,
          ),
          SizedBox(height: 12),
          Text(
            'No food items yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF17183B),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Scan or add your first product to start tracking expiration dates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
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

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.bottomNavigationBar,
            ),
            const SizedBox(height: 14),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF17183B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryColors {
  final Color fill;
  final Color border;

  const _ExpiryColors({
    required this.fill,
    required this.border,
  });
}

_ExpiryColors _colorsForExpiryState(String expiryState) {
  switch (expiryState) {
    case 'expired':
      return const _ExpiryColors(
        fill: AppColors.expiredFill,
        border: AppColors.freshBorder,
      );
    case 'expiring':
      return const _ExpiryColors(
        fill: AppColors.expiringTomorrowFill,
        border: AppColors.freshBorder,
      );
    case 'fresh':
    default:
      return const _ExpiryColors(
        fill: AppColors.freshFill,
        border: AppColors.freshBorder,
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
      return Icons.category_outlined;
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
