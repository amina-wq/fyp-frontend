import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/inventory/inventory.dart';
import '../../core/constants/api_constants.dart';
import '../../models/inventory/inventory.dart';
import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';

@RoutePage()
class InventoryItemDetailsScreen extends StatefulWidget {
  final InventoryItemModel item;

  const InventoryItemDetailsScreen({super.key, required this.item});

  @override
  State<InventoryItemDetailsScreen> createState() =>
      _InventoryItemDetailsScreenState();
}

class _InventoryItemDetailsScreenState
    extends State<InventoryItemDetailsScreen> {
  late InventoryItemModel _item;
  bool _isDeleting = false;
  bool _isConsuming = false;

  bool get _isBusy => _isDeleting || _isConsuming;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEditScreen() async {
    if (_isBusy) return;

    final updatedItem = await context.router.push<InventoryItemModel>(
      EditInventoryItemRoute(item: _item),
    );

    if (updatedItem == null) return;

    setState(() {
      _item = updatedItem;
    });
  }

  Future<void> _addToShoppingList() async {
    if (_isBusy) return;

    await showAddToShoppingListDialog(
      context: context,
      initialName: _item.displayName,
      initialCategoryId: _item.categoryId,
      source: 'inventory',
      sourceId: _item.id,
      initialAmount: _item.amount,
      initialUnit: _item.unit,
      allowNameEditing: false,
      allowCategoryEditing: false,
    );
  }

  Future<void> _confirmDeleteItem() async {
    if (_isBusy) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;

        return AlertDialog(
          backgroundColor: colors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete item?',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to remove ${_item.displayName} from your inventory?',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    if (!mounted) return;

    _deleteItem();
  }

  void _deleteItem() {
    setState(() {
      _isDeleting = true;
    });

    context.read<InventoryBloc>().add(
      InventoryItemDeleteRequested(itemId: _item.id),
    );
  }

  void _consumeItem() {
    if (_isBusy) return;

    setState(() {
      _isConsuming = true;
    });

    context.read<InventoryBloc>().add(
      InventoryItemConsumeRequested(itemId: _item.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (!_isBusy) return;

        if (state is InventoryLoadSuccess) {
          final message = _isDeleting
              ? '${_item.displayName} removed from inventory'
              : '${_item.displayName} marked as consumed';

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));

          context.router.maybePop();
          return;
        }

        if (state is InventoryFailure) {
          setState(() {
            _isDeleting = false;
            _isConsuming = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _DetailsHeader(
                isDeleting: _isBusy,
                onBack: () => context.router.maybePop(),
                onDelete: _confirmDeleteItem,
                onEdit: _openEditScreen,
              ),
              const SizedBox(height: 24),
              _ProductImagePlaceholder(
                categoryKey: _item.categoryKey,
                categoryIconUrl: _item.categoryIconUrl,
                imageUrl: _bestImageUrlForItem(_item),
              ),
              const SizedBox(height: 22),
              _AddToShoppingListButton(onTap: _addToShoppingList),
              const SizedBox(height: 12),
              _MarkConsumedButton(
                isLoading: _isConsuming,
                onTap: _isBusy ? null : _consumeItem,
              ),
              const SizedBox(height: 18),
              _DetailsCard(
                children: [
                  _DetailsField(
                    icon: Icons.shopping_bag_outlined,
                    label: _item.displayName,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailsField(
                          icon: Icons.numbers_outlined,
                          label: _formatAmount(_item.amount),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailsField(
                          icon: Icons.straighten_outlined,
                          label: _item.unit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailsField(
                    icon: Icons.calendar_month_outlined,
                    label: _formatDate(_item.expirationDate),
                    sublabel: _item.bestBeforeDate != null
                        ? 'Best before ${_formatDate(_item.bestBeforeDate!)}'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _DetailsField(
                    icon: Icons.category_outlined,
                    label: _item.categoryName,
                  ),
                  const SizedBox(height: 12),
                  _DetailsField(
                    icon: Icons.location_on_outlined,
                    label: _formatText(_item.location),
                  ),
                  const SizedBox(height: 12),
                  _NotesField(notes: _item.notes),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _DetailsHeader({
    required this.isDeleting,
    required this.onBack,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        _HeaderButton(icon: Icons.chevron_left, onTap: onBack),
        Expanded(
          child: Text(
            'Product Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _HeaderButton(
          icon: isDeleting
              ? Icons.hourglass_empty_outlined
              : Icons.delete_outline,
          iconColor: colors.danger,
          onTap: isDeleting ? null : onDelete,
        ),
        const SizedBox(width: 10),
        _HeaderButton(
          icon: Icons.edit_outlined,
          onTap: isDeleting ? null : onEdit,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _HeaderButton({
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          icon,
          color: onTap == null ? colors.textMuted : iconColor ?? colors.primary,
          size: 24,
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  final String categoryKey;
  final String? categoryIconUrl;
  final String? imageUrl;

  const _ProductImagePlaceholder({
    required this.categoryKey,
    required this.categoryIconUrl,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasProductImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasCategoryIcon =
        categoryIconUrl != null && categoryIconUrl!.isNotEmpty;

    return Center(
      child: Container(
        width: 180,
        height: 180,
        clipBehavior: Clip.antiAlias,
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
        child: hasProductImage
            ? AppCachedNetworkImage(
                imageUrl: imageUrl!,
                fallback: _CategoryIcon(
                  categoryKey: categoryKey,
                  categoryIconUrl: categoryIconUrl,
                ),
              )
            : hasCategoryIcon
            ? AppCachedNetworkImage(
                imageUrl: categoryIconUrl!,
                fallback: Icon(
                  _iconForCategory(categoryKey),
                  size: 78,
                  color: colors.primary,
                ),
              )
            : Icon(
                _iconForCategory(categoryKey),
                size: 78,
                color: colors.primary,
              ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String categoryKey;
  final String? categoryIconUrl;

  const _CategoryIcon({
    required this.categoryKey,
    required this.categoryIconUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (categoryIconUrl != null && categoryIconUrl!.isNotEmpty) {
      return AppCachedNetworkImage(
        imageUrl: categoryIconUrl!,
        fallback: Icon(
          _iconForCategory(categoryKey),
          size: 78,
          color: colors.primary,
        ),
      );
    }

    return Icon(_iconForCategory(categoryKey), size: 78, color: colors.primary);
  }
}

class _AddToShoppingListButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddToShoppingListButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.playlist_add_outlined, size: 22),
        label: const Text(
          'Add to Shopping List',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _MarkConsumedButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _MarkConsumedButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textOnPrimary,
                ),
              )
            : const Icon(Icons.check_circle_outline, size: 22),
        label: Text(
          isLoading ? 'Marking as consumed…' : 'Mark as Consumed',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.success,
          foregroundColor: colors.textOnPrimary,
          disabledBackgroundColor: colors.success.withValues(alpha: 0.6),
          disabledForegroundColor: colors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailsField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;

  const _DetailsField({required this.icon, required this.label, this.sublabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final String? notes;

  const _NotesField({required this.notes});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isEmpty = notes == null || notes!.trim().isEmpty;
    final text = isEmpty ? 'Notes' : notes!.trim();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_outlined, color: colors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isEmpty ? colors.textMuted : colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatAmount(double amount) {
  if (amount % 1 == 0) {
    return amount.toStringAsFixed(0);
  }

  return amount.toStringAsFixed(1);
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day.$month.$year';
}

String _formatText(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      })
      .join(' ');
}

IconData _iconForCategory(String categoryKey) {
  switch (categoryKey) {
    case 'dairy':
      return Icons.local_drink_outlined;
    case 'meat':
      return Icons.set_meal_outlined;
    case 'seafood':
      return Icons.phishing_outlined;
    case 'fruits':
      return Icons.food_bank_outlined;
    case 'vegetables':
      return Icons.eco_outlined;
    case 'bakery':
      return Icons.bakery_dining_outlined;
    case 'grains':
      return Icons.grain_outlined;
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
      return Icons.kitchen_outlined;
    case 'other':
    default:
      return Icons.dinner_dining_outlined;
  }
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
