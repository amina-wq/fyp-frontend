import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/categories/categories.dart';
import '../../bloc/shopping_list/shopping_list_bloc.dart';
import '../../bloc/shopping_list/shopping_list_event.dart';
import '../../models/categories/categories.dart';
import '../../models/shopping_list/shopping_list.dart';
import '../theme/app_colors.dart';

Future<void> showAddToShoppingListDialog({
  required BuildContext context,
  String initialName = '',
  String? initialCategoryId,
  String source = 'manual',
  String? sourceId,
  double? initialAmount,
  String? initialUnit,
  bool allowNameEditing = true,
  bool allowCategoryEditing = true,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AddToShoppingListDialog(
        parentContext: context,
        initialName: initialName,
        initialCategoryId: initialCategoryId,
        source: source,
        sourceId: sourceId,
        initialAmount: initialAmount,
        initialUnit: initialUnit,
        allowNameEditing: allowNameEditing,
        allowCategoryEditing: allowCategoryEditing,
      );
    },
  );
}

class AddToShoppingListDialog extends StatefulWidget {
  final BuildContext parentContext;
  final String initialName;
  final String? initialCategoryId;
  final String source;
  final String? sourceId;
  final double? initialAmount;
  final String? initialUnit;
  final bool allowNameEditing;
  final bool allowCategoryEditing;

  const AddToShoppingListDialog({
    super.key,
    required this.parentContext,
    required this.initialName,
    required this.initialCategoryId,
    required this.source,
    required this.sourceId,
    required this.allowNameEditing,
    required this.allowCategoryEditing,
    this.initialAmount,
    this.initialUnit,
  });

  @override
  State<AddToShoppingListDialog> createState() =>
      _AddToShoppingListDialogState();
}

class _AddToShoppingListDialogState extends State<AddToShoppingListDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  String? _selectedCategoryId;
  late String? _selectedUnit;

  final List<String> _units = const [
    'pcs',
    'g',
    'kg',
    'ml',
    'l',
    'pack',
    'bottle',
    'can',
    'other',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);

    _amountController = TextEditingController(
      text: widget.initialAmount == null
          ? ''
          : _formatAmount(widget.initialAmount!),
    );

    _selectedCategoryId = widget.initialCategoryId;

    _selectedUnit = _units.contains(widget.initialUnit)
        ? widget.initialUnit
        : null;

    widget.parentContext.read<CategoriesBloc>().add(
      const CategoriesLoadRequested(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _defaultCategoryId(List<CategoryModel> categories) {
    for (final category in categories) {
      if (category.key == 'other') {
        return category.id;
      }
    }

    if (categories.isEmpty) {
      return null;
    }

    return categories.first.id;
  }

  void _addItem() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = amountText.isEmpty ? null : double.tryParse(amountText);

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter item name')));
      return;
    }

    if (amountText.isNotEmpty && amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select category')));
      return;
    }

    widget.parentContext.read<ShoppingListBloc>().add(
      ShoppingListItemCreateRequested(
        item: ShoppingListItemCreateModel(
          name: name,
          categoryId: _selectedCategoryId!,
          amount: amount,
          unit: _selectedUnit,
          source: widget.source,
          sourceId: widget.sourceId,
        ),
      ),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(
      widget.parentContext,
    ).showSnackBar(SnackBar(content: Text('$name added to shopping list')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AlertDialog(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.border),
      ),
      title: Text(
        'Add to Shopping List',
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              enabled: widget.allowNameEditing,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: _inputDecoration(
                context: context,
                label: 'Item name',
                hint: 'Milk',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: _inputDecoration(
                context: context,
                label: 'Amount',
                hint: 'Optional',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              dropdownColor: colors.card,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              items: [
                const DropdownMenuItem<String>(child: Text('No unit')),
                ..._units.map(
                  (unit) =>
                      DropdownMenuItem<String>(value: unit, child: Text(unit)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value;
                });
              },
              decoration: _inputDecoration(
                context: context,
                label: 'Unit',
                hint: 'Optional',
              ),
            ),
            const SizedBox(height: 14),
            BlocBuilder<CategoriesBloc, CategoriesState>(
              bloc: widget.parentContext.read<CategoriesBloc>(),
              builder: (context, categoriesState) {
                if (categoriesState is CategoriesLoading ||
                    categoriesState is CategoriesInitial) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  );
                }

                if (categoriesState is CategoriesFailure) {
                  return Text(
                    categoriesState.message,
                    style: TextStyle(
                      color: colors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }

                if (categoriesState is! CategoriesLoaded) {
                  return const SizedBox.shrink();
                }

                final categories = categoriesState.categories;

                if (_selectedCategoryId == null && categories.isNotEmpty) {
                  _selectedCategoryId = _defaultCategoryId(categories);
                }

                final hasSelectedCategory = categories.any(
                  (category) => category.id == _selectedCategoryId,
                );

                return DropdownButtonFormField<String>(
                  value: hasSelectedCategory ? _selectedCategoryId : null,
                  dropdownColor: colors.card,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: widget.allowCategoryEditing
                      ? (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      : null,
                  decoration: _inputDecoration(
                    context: context,
                    label: 'Category',
                    hint: 'Category',
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.textOnPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({
  required BuildContext context,
  required String label,
  required String hint,
}) {
  final colors = context.appColors;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(
      color: colors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: TextStyle(
      color: colors.textMuted,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: colors.surfaceSoft,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.primary, width: 1.4),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.border),
    ),
  );
}

String _formatAmount(double amount) {
  if (amount % 1 == 0) {
    return amount.toStringAsFixed(0);
  }

  return amount.toStringAsFixed(1);
}
