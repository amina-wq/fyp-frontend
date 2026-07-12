import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/categories/categories.dart';
import '../../bloc/inventory/inventory.dart';
import '../../models/categories/categories.dart';
import '../../models/inventory/inventory.dart';
import '../../models/product/product.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';

@RoutePage()
class AddScannedProductScreen extends StatefulWidget {
  final ProductModel product;

  const AddScannedProductScreen({super.key, required this.product});

  @override
  State<AddScannedProductScreen> createState() =>
      _AddScannedProductScreenState();
}

class _AddScannedProductScreenState extends State<AddScannedProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _pickedImage;

  String? _selectedCategoryId;
  String _selectedLocation = 'fridge';
  String _selectedUnit = 'pcs';
  DateTime? _expirationDate;

  bool _isSaving = false;

  static const _locations = [
    _OptionItem('fridge', 'Fridge'),
    _OptionItem('freezer', 'Freezer'),
    _OptionItem('pantry', 'Pantry'),
    _OptionItem('counter', 'Counter'),
    _OptionItem('other', 'Other'),
  ];

  static const _units = [
    _OptionItem('pcs', 'pcs'),
    _OptionItem('g', 'g'),
    _OptionItem('kg', 'kg'),
    _OptionItem('ml', 'ml'),
    _OptionItem('l', 'l'),
    _OptionItem('pack', 'pack'),
    _OptionItem('bottle', 'bottle'),
    _OptionItem('can', 'can'),
    _OptionItem('other', 'other'),
  ];

  @override
  void initState() {
    super.initState();

    context.read<CategoriesBloc>().add(const CategoriesLoadRequested());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    setState(() {
      _expirationDate = pickedDate;
    });
  }

  Future<void> _takePhoto() async {
    if (_isSaving) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1200,
    );

    if (pickedImage == null) return;
    if (!mounted) return;

    setState(() {
      _pickedImage = pickedImage;
    });
  }

  void _removePhoto() {
    if (_isSaving) return;

    setState(() {
      _pickedImage = null;
    });
  }

  void _saveProductToInventory() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    if (_selectedCategoryId == null) {
      _showMessage('Please select category');
      return;
    }

    if (_expirationDate == null) {
      _showMessage('Please select expiration date');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('Please enter valid amount');
      return;
    }

    setState(() => _isSaving = true);

    context.read<InventoryBloc>().add(
      InventoryItemCreateRequested(
        data: InventoryItemCreateModel(
          productId: widget.product.id,
          barcode: widget.product.barcode,
          customName: null,
          categoryId: _selectedCategoryId!,
          notes: _cleanOptionalText(_notesController.text),
          location: _selectedLocation,
          amount: amount,
          unit: _selectedUnit,
          expirationDate: _expirationDate!,
        ),
        imagePath: _pickedImage?.path,
      ),
    );
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

  String? _cleanOptionalText(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (!_isSaving) return;

        if (state is InventoryLoadSuccess) {
          setState(() => _isSaving = false);

          context.router.popUntilRoot();
        }

        if (state is InventoryFailure) {
          setState(() => _isSaving = false);

          _showMessage(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _Header(
                  onBack: () {
                    if (_isSaving) return;
                    context.router.maybePop();
                  },
                  onSave: _isSaving ? null : _saveProductToInventory,
                  isSaving: _isSaving,
                ),
                const SizedBox(height: 24),
                _ProductPreviewCard(product: widget.product),
                const SizedBox(height: 18),
                _ProductPhotoPicker(
                  localImagePath: _pickedImage?.path,
                  onTakePhoto: _isSaving ? null : _takePhoto,
                  onRemovePhoto: _isSaving || _pickedImage == null
                      ? null
                      : _removePhoto,
                ),
                const SizedBox(height: 18),
                _FormCard(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TextInput(
                            controller: _amountController,
                            label: 'Amount',
                            icon: Icons.numbers_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              final amount = double.tryParse(text);

                              if (amount == null || amount <= 0) {
                                return 'Invalid amount';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DropdownInput(
                            label: 'Unit',
                            icon: Icons.straighten_outlined,
                            value: _selectedUnit,
                            items: _units,
                            onChanged: (value) {
                              setState(() => _selectedUnit = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DateInput(
                      selectedDate: _expirationDate,
                      onTap: _pickExpirationDate,
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, categoriesState) {
                        if (categoriesState is CategoriesLoading ||
                            categoriesState is CategoriesInitial) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colors.primary,
                            ),
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

                        if (_selectedCategoryId == null &&
                            categories.isNotEmpty) {
                          _selectedCategoryId = _defaultCategoryId(categories);
                        }

                        return _CategoryDropdownInput(
                          label: 'Category',
                          icon: Icons.category_outlined,
                          value: _selectedCategoryId,
                          categories: categories,
                          onChanged: (value) {
                            setState(() => _selectedCategoryId = value);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DropdownInput(
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                      value: _selectedLocation,
                      items: _locations,
                      onChanged: (value) {
                        setState(() => _selectedLocation = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _TextInput(
                      controller: _notesController,
                      label: 'Notes',
                      icon: Icons.notes_outlined,
                      maxLines: 4,
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.length > 500) {
                          return 'Maximum 500 characters';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onSave;
  final bool isSaving;

  const _Header({
    required this.onBack,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        _HeaderButton(icon: Icons.chevron_left, onTap: onBack),
        Expanded(
          child: Text(
            'Add Scanned Product',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _HeaderButton(
          icon: Icons.check_circle_outline,
          onTap: onSave,
          isLoading: isSaving,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(11),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: colors.primary,
                ),
              )
            : Icon(
                icon,
                color: onTap == null ? colors.textMuted : colors.primary,
                size: 24,
              ),
      ),
    );
  }
}

class _ProductPreviewCard extends StatelessWidget {
  final ProductModel product;

  const _ProductPreviewCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: product.imageUrl == null || product.imageUrl!.isEmpty
                ? Icon(
                    Icons.inventory_2_outlined,
                    color: colors.primary,
                    size: 34,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AppCachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fallback: Icon(
                        Icons.inventory_2_outlined,
                        color: colors.primary,
                        size: 34,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (product.brand != null && product.brand!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    product.brand!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    product.barcode!,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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

class _ProductPhotoPicker extends StatelessWidget {
  final String? localImagePath;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onRemovePhoto;

  const _ProductPhotoPicker({
    required this.localImagePath,
    required this.onTakePhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasImage = localImagePath != null && localImagePath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: hasImage
                ? Image.file(File(localImagePath!), fit: BoxFit.cover)
                : Icon(
                    Icons.camera_alt_outlined,
                    size: 54,
                    color: colors.primary,
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onTakePhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(hasImage ? 'Retake photo' : 'Take photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      disabledForegroundColor: colors.textMuted,
                      side: BorderSide(color: colors.primaryBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              if (onRemovePhoto != null) ...[
                const SizedBox(width: 12),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onRemovePhoto,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      disabledForegroundColor: colors.textMuted,
                      side: BorderSide(color: colors.dangerBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.delete_outline),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(context: context, label: label, icon: icon),
    );
  }
}

class _CategoryDropdownInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<CategoryModel> categories;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdownInput({
    required this.label,
    required this.icon,
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasSelectedValue = categories.any((category) => category.id == value);

    return DropdownButtonFormField<String>(
      value: hasSelectedValue ? value : null,
      isExpanded: true,
      dropdownColor: colors.card,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(context: context, label: label, icon: icon),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _DropdownInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<_OptionItem> items;
  final ValueChanged<String> onChanged;

  const _DropdownInput({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: colors.card,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(context: context, label: label, icon: icon),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item.value,
          child: Text(item.label),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        onChanged(value);
      },
    );
  }
}

class _DateInput extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DateInput({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasDate = selectedDate != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          context: context,
          label: 'Expiration date',
          icon: Icons.calendar_month_outlined,
        ),
        child: Text(
          hasDate ? _formatDate(selectedDate!) : 'Select date',
          style: TextStyle(
            color: hasDate ? colors.textPrimary : colors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OptionItem {
  final String value;
  final String label;

  const _OptionItem(this.value, this.label);
}

InputDecoration _inputDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  final colors = context.appColors;

  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: colors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(icon, color: colors.primary, size: 21),
    filled: true,
    fillColor: colors.surfaceSoft,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.dangerBorder),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.danger, width: 1.5),
    ),
    errorStyle: TextStyle(color: colors.danger, fontWeight: FontWeight.w700),
  );
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day.$month.$year';
}
