import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/inventory/inventory.dart';
import '../../ui/theme/app_colors.dart';
import '../../router/router.dart';

@RoutePage()
class InventoryItemDetailsScreen extends StatefulWidget {
  final InventoryItemModel item;

  const InventoryItemDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<InventoryItemDetailsScreen> createState() =>
      _InventoryItemDetailsScreenState();
}

class _InventoryItemDetailsScreenState
    extends State<InventoryItemDetailsScreen> {
  late InventoryItemModel _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEditScreen() async {
    final updatedItem = await context.router.push<InventoryItemModel>(
      EditInventoryItemRoute(item: _item),
    );

    if (updatedItem == null) return;

    setState(() {
      _item = updatedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _DetailsHeader(
              onBack: () => context.router.maybePop(),
              onEdit: _openEditScreen,
            ),
            const SizedBox(height: 24),
            _ProductImagePlaceholder(
              category: _item.category,
              imageUrl: _bestImageUrlForItem(_item),
            ),
            const SizedBox(height: 26),
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
                ),
                const SizedBox(height: 12),
                _DetailsField(
                  icon: Icons.category_outlined,
                  label: _formatText(_item.category),
                ),
                const SizedBox(height: 12),
                _DetailsField(
                  icon: Icons.location_on_outlined,
                  label: _formatText(_item.location),
                ),
                const SizedBox(height: 12),
                _NotesField(
                  notes: _item.notes,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _DetailsHeader({
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.chevron_left,
          onTap: onBack,
        ),
        const Expanded(
          child: Text(
            'Product Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2147),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _HeaderButton(
          icon: Icons.edit_outlined,
          onTap: onEdit,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.categoryActiveFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.bottomNavigationBar,
          size: 24,
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  final String category;
  final String? imageUrl;

  const _ProductImagePlaceholder({
    required this.category,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Center(
      child: Container(
        width: 180,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: hasImage
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              _iconForCategory(category),
              size: 78,
              color: AppColors.bottomNavigationBar,
            );
          },
        )
            : Icon(
          _iconForCategory(category),
          size: 78,
          color: AppColors.bottomNavigationBar,
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailsField extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailsField({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.categoryActiveFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.categoryActiveBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.bottomNavigationBar,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1F2147),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final String? notes;

  const _NotesField({
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final text = notes == null || notes!.trim().isEmpty
        ? 'Notes'
        : notes!.trim();

    return Container(
      width: double.infinity,
      height: 92,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.categoryActiveFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.categoryActiveBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notes_outlined,
            color: AppColors.bottomNavigationBar,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: notes == null || notes!.trim().isEmpty
                    ? Colors.black45
                    : const Color(0xFF1F2147),
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

IconData _iconForCategory(String category) {
  switch (category) {
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
      return Icons.category_outlined;
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
