import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/add_manual_product/add_manual_product.dart';
import '../../bloc/inventory/inventory.dart';
import '../../models/inventory/inventory.dart';
import '../../models/product/product.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class AddManualProductScreen extends StatefulWidget {
  const AddManualProductScreen({
    super.key,
    this.prefilledBarcode,
  });

  final String? prefilledBarcode;

  @override
  State<AddManualProductScreen> createState() => _AddManualProductScreenState();
}

class _AddManualProductScreenState extends State<AddManualProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcodeController;
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _amountController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  String _selectedCategory = 'other';
  String _selectedLocation = 'fridge';
  String _selectedUnit = 'pcs';
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();

    _barcodeController = TextEditingController(
      text: widget.prefilledBarcode ?? '',
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

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
          imageUrl: _cleanOptionalText(_imageUrlController.text),
          quantity: _cleanOptionalText(_quantityController.text),
        ),
        inventoryData: InventoryItemCreateModel(
          productId: null,
          barcode: _cleanOptionalText(_barcodeController.text),
          customName: null,
          category: _selectedCategory,
          notes: _cleanOptionalText(_notesController.text),
          location: _selectedLocation,
          amount: amount,
          unit: _selectedUnit,
          expirationDate: _expirationDate!,
        ),
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

    setState(() {
      _expirationDate = pickedDate;
    });
  }

  String? _cleanOptionalText(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddManualProductBloc, AddManualProductState>(
      listener: (context, state) {
        if (state is AddManualProductSuccess) {
          context.read<InventoryBloc>().add(
            const InventoryLoadRequested(),
          );

          context.router.maybePop();
        }

        if (state is AddManualProductFailure) {
          _showMessage(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _Header(
                  onBack: () => context.router.maybePop(),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 12),
                _TextInput(
                  controller: _imageUrlController,
                  label: 'Image URL',
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 24),
                _DropdownInput(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  value: _selectedCategory,
                  items: const [
                    _OptionItem('dairy', 'Dairy'),
                    _OptionItem('meat', 'Meat'),
                    _OptionItem('seafood', 'Seafood'),
                    _OptionItem('fruits', 'Fruits'),
                    _OptionItem('vegetables', 'Vegetables'),
                    _OptionItem('bakery', 'Bakery'),
                    _OptionItem('grains', 'Grains'),
                    _OptionItem('beverages', 'Beverages'),
                    _OptionItem('snacks', 'Snacks'),
                    _OptionItem('frozen', 'Frozen'),
                    _OptionItem('canned', 'Canned'),
                    _OptionItem('cooked_food', 'Cooked food'),
                    _OptionItem('leftovers', 'Leftovers'),
                    _OptionItem('condiments', 'Condiments'),
                    _OptionItem('other', 'Other'),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
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
                const SizedBox(height: 28),
                BlocBuilder<AddManualProductBloc, AddManualProductState>(
                  builder: (context, state) {
                    final isSaving = state is AddManualProductSaving;

                    return SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bottomNavigationBar,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Save product',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  },
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

  const _Header({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.categoryActiveFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.bottomNavigationBar,
              size: 28,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Add Product',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2147),
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
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
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
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
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

  const _DateInput({
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: 'Expiration date *',
          icon: Icons.calendar_month_outlined,
        ),
        child: Text(
          selectedDate == null ? 'Select date' : _formatDate(selectedDate!),
          style: TextStyle(
            color: selectedDate == null ? Colors.black45 : AppColors.textDark,
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

  const _OptionItem(
      this.value,
      this.label,
      );
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Color(0xFF52656E),
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(
      icon,
      color: AppColors.bottomNavigationBar,
      size: 21,
    ),
    filled: true,
    fillColor: AppColors.categoryActiveFill,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.categoryActiveBorder,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.categoryActiveBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.bottomNavigationBar,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.expiredBorder,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.expiredBorder,
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day.$month.$year';
}