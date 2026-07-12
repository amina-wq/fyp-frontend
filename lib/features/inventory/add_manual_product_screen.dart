import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/add_manual_product/add_manual_product.dart';
import '../../bloc/categories/categories.dart';
import '../../bloc/inventory/inventory.dart';
import '../../models/categories/categories.dart';
import '../../models/inventory/inventory.dart';
import '../../models/product/product.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class AddManualProductScreen extends StatefulWidget {
  const AddManualProductScreen({super.key, this.prefilledBarcode});

  final String? prefilledBarcode;

  @override
  State<AddManualProductScreen> createState() => _AddManualProductScreenState();
}

class _AddManualProductScreenState extends State<AddManualProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _barcodeController;
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _tagsController = TextEditingController();

  final _amountController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  XFile? _pickedImage;

  String? _selectedCategoryId;
  String _selectedLocation = 'fridge';
  String _selectedUnit = 'pcs';
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();

    _barcodeController = TextEditingController(
      text: widget.prefilledBarcode ?? '',
    );

    context.read<CategoriesBloc>().add(const CategoriesLoadRequested());
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
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
    setState(() {
      _pickedImage = null;
    });
  }

  void _submit() {
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

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    context.read<AddManualProductBloc>().add(
      AddManualProductSaveRequested(
        productData: ManualProductCreateModel(
          barcode: _cleanOptionalText(_barcodeController.text),
          name: _nameController.text.trim(),
          brand: _cleanOptionalText(_brandController.text),
          tags: tags,
          imageUrl: null,
          quantity: _cleanOptionalText(_quantityController.text),
        ),
        inventoryData: InventoryItemCreateModel(
          productId: null,
          barcode: _cleanOptionalText(_barcodeController.text),
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

    return BlocListener<AddManualProductBloc, AddManualProductState>(
      listener: (context, state) {
        if (state is AddManualProductSuccess) {
          context.read<InventoryBloc>().add(const InventoryLoadRequested());

          context.router.maybePop(state.item);
        }

        if (state is AddManualProductFailure) {
          _showMessage(state.message);
        }
      },
      child: BlocBuilder<AddManualProductBloc, AddManualProductState>(
        builder: (context, state) {
          final isSaving = state is AddManualProductSaving;

          return Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _Header(
                      onBack: () {
                        if (isSaving) return;

                        context.router.maybePop();
                      },
                    ),
                    const SizedBox(height: 24),
                    _FormCard(
                      children: [
                        _TextInput(
                          controller: _nameController,
                          label: 'Product name *',
                          icon: Icons.shopping_bag_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Product name is required';
                            }

                            if (text.length > 150) {
                              return 'Maximum 150 characters';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _TextInput(
                          controller: _barcodeController,
                          label: 'Barcode',
                          icon: Icons.qr_code_2_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.length > 50) {
                              return 'Maximum 50 characters';
                            }

                            if (text.contains(' ')) {
                              return 'Barcode cannot contain spaces';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _TextInput(
                          controller: _brandController,
                          label: 'Brand',
                          icon: Icons.store_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.length > 100) {
                              return 'Maximum 100 characters';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _TextInput(
                          controller: _quantityController,
                          label: 'Product quantity, e.g. 1L or 500g',
                          icon: Icons.scale_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.length > 50) {
                              return 'Maximum 50 characters';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _TextInput(
                          controller: _tagsController,
                          label: 'Tags, separated by comma',
                          icon: Icons.sell_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ProductPhotoPicker(
                      localImagePath: _pickedImage?.path,
                      onTakePhoto: isSaving ? null : _takePhoto,
                      onRemovePhoto: isSaving || _pickedImage == null
                          ? null
                          : _removePhoto,
                    ),
                    const SizedBox(height: 18),
                    _FormCard(
                      children: [
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
                              _selectedCategoryId = _defaultCategoryId(
                                categories,
                              );
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
                        Row(
                          children: [
                            Expanded(
                              child: _TextInput(
                                controller: _amountController,
                                label: 'Amount *',
                                icon: Icons.numbers_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropdownInput(
                                label: 'Unit',
                                icon: Icons.straighten_outlined,
                                value: _selectedUnit,
                                items: const [
                                  _OptionItem('pcs', 'pcs'),
                                  _OptionItem('g', 'g'),
                                  _OptionItem('kg', 'kg'),
                                  _OptionItem('ml', 'ml'),
                                  _OptionItem('l', 'l'),
                                  _OptionItem('pack', 'pack'),
                                  _OptionItem('bottle', 'bottle'),
                                  _OptionItem('can', 'can'),
                                  _OptionItem('other', 'other'),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedUnit = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DropdownInput(
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                          value: _selectedLocation,
                          items: const [
                            _OptionItem('fridge', 'Fridge'),
                            _OptionItem('freezer', 'Freezer'),
                            _OptionItem('pantry', 'Pantry'),
                            _OptionItem('counter', 'Counter'),
                            _OptionItem('other', 'Other'),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedLocation = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _DateInput(
                          selectedDate: _expirationDate,
                          onTap: _pickExpirationDate,
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
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.textOnPrimary,
                          disabledBackgroundColor: colors.surfaceSoft,
                          disabledForegroundColor: colors.textMuted,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isSaving
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: colors.textOnPrimary,
                                ),
                              )
                            : const Text(
                                'Save product',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.chevron_left, color: colors.primary, size: 28),
          ),
        ),
        Expanded(
          child: Text(
            'Add Product',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          context: context,
          label: 'Expiration date *',
          icon: Icons.calendar_month_outlined,
        ),
        child: Text(
          selectedDate == null ? 'Select date' : _formatDate(selectedDate!),
          style: TextStyle(
            color: selectedDate == null ? colors.textMuted : colors.textPrimary,
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
