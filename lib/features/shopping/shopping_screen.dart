// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Shopping list screen.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Tuesday, 14-Jul-2026
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/shopping_list/shopping_list.dart';
import '../../models/shopping_list/shopping_list.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';

@RoutePage()
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ShoppingListBloc>().add(const ShoppingListLoadRequested());
  }

  Future<void> _openManualAddDialog() async {
    await showAddToShoppingListDialog(context: context);
  }

  Widget _buildBody(BuildContext context, ShoppingListState state) {
    final colors = context.appColors;

    if (state is ShoppingListInitial || state is ShoppingListLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    if (state is ShoppingListFailure) {
      return _ShoppingErrorView(
        message: state.message,
        onRetry: () {
          context.read<ShoppingListBloc>().add(
            const ShoppingListLoadRequested(),
          );
        },
      );
    }

    if (state is ShoppingListLoaded) {
      if (state.items.isEmpty) {
        return _EmptyShoppingListView(onAddItem: _openManualAddDialog);
      }

      return RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.card,
        onRefresh: () async {
          context.read<ShoppingListBloc>().add(
            const ShoppingListLoadRequested(),
          );
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            if (state.uncheckedItems.isNotEmpty) ...[
              _SectionHeader(
                title: 'To buy',
                count: state.uncheckedItems.length,
              ),
              const SizedBox(height: 10),
              ...state.uncheckedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ShoppingItemTile(
                    item: item,
                    subtitle: _buildSubtitle(item),
                    onToggle: () {
                      context.read<ShoppingListBloc>().add(
                        ShoppingListItemToggleRequested(itemId: item.id),
                      );
                    },
                    onDelete: () {
                      context.read<ShoppingListBloc>().add(
                        ShoppingListItemDeleteRequested(itemId: item.id),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (state.checkedItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionHeader(
                title: 'Checked',
                count: state.checkedItems.length,
              ),
              const SizedBox(height: 10),
              ...state.checkedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ShoppingItemTile(
                    item: item,
                    subtitle: _buildSubtitle(item),
                    onToggle: () {
                      context.read<ShoppingListBloc>().add(
                        ShoppingListItemToggleRequested(itemId: item.id),
                      );
                    },
                    onDelete: () {
                      context.read<ShoppingListBloc>().add(
                        ShoppingListItemDeleteRequested(itemId: item.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _buildSubtitle(ShoppingListItemModel item) {
    final amount = item.amount;
    final unit = item.unit;
    final categoryName = item.categoryName;

    if (amount == null && unit == null) {
      return categoryName;
    }

    if (amount != null && unit != null) {
      return '${_formatAmount(amount)} $unit · $categoryName';
    }

    if (amount != null) {
      return '${_formatAmount(amount)} · $categoryName';
    }

    return '$unit · $categoryName';
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<ShoppingListBloc, ShoppingListState>(
      listener: (context, state) {
        if (state is ShoppingListFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _ShoppingHeader(
                  onAdd: _openManualAddDialog,
                  onRefresh: () {
                    context.read<ShoppingListBloc>().add(
                      const ShoppingListLoadRequested(),
                    );
                  },
                  onClearChecked: () {
                    context.read<ShoppingListBloc>().add(
                      const ShoppingListCheckedClearRequested(),
                    );
                  },
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShoppingHeader extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final VoidCallback onClearChecked;

  const _ShoppingHeader({
    required this.onAdd,
    required this.onRefresh,
    required this.onClearChecked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Shopping List',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          _HeaderIconButton(icon: Icons.add, tooltip: 'Add item', onTap: onAdd),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onTap: onRefresh,
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.cleaning_services_outlined,
            tooltip: 'Clear checked',
            onTap: onClearChecked,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, color: colors.primary, size: 22),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: colors.chipSelected,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.chipSelectedBorder),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingListItemModel item;
  final String subtitle;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingItemTile({
    required this.item,
    required this.subtitle,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: colors.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: item.isChecked
                ? Border.all(color: colors.successBorder)
                : null,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: item.isChecked,
                onChanged: (_) => onToggle(),
                activeColor: colors.primary,
                checkColor: colors.textOnPrimary,
                side: BorderSide(
                  color: item.isChecked ? colors.primary : colors.border,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.isChecked
                            ? colors.textMuted
                            : colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                item.isChecked
                    ? Icons.check_circle_outline
                    : Icons.shopping_cart_outlined,
                color: item.isChecked ? colors.success : colors.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShoppingListView extends StatelessWidget {
  final VoidCallback onAddItem;

  const _EmptyShoppingListView({required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Shopping list is empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add products manually or from your inventory.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add),
                label: const Text('Add item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.textOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ShoppingErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 52, color: colors.danger),
            const SizedBox(height: 16),
            Text(
              'Failed to load shopping list',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
