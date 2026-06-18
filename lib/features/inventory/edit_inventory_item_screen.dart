import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/inventory/inventory.dart';
import '../../core/constants/api_constants.dart';
import '../../models/inventory/inventory.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class EditInventoryItemScreen extends StatefulWidget {
  final InventoryItemModel item;

  const EditInventoryItemScreen({
    super.key,
    required this.item,
  });

  @override
  State<EditInventoryItemScreen> createState() =>
      _EditInventoryItemScreenState();
}

class _EditInventoryItemScreenState extends State<EditInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late InventoryItemModel _currentItem;

  late final TextEditingController _customNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late String _selectedCategory;
  late String _selectedLocation;
  late String _selectedUnit;
  late DateTime _expirationDate;

  XFile? _pickedImage;

  bool _isSaving = false;
  bool _isImageUploading = false;
  bool _isImageDeleting = false;

  static const _categories = [
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
  ];

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

    _currentItem = widget.item;

    _customNameController = TextEditingController(
      text: _currentItem.customName ?? _currentItem.displayName,
    );

    _amountController = TextEditingController(
      text: _formatAmountForInput(_currentItem.amount),
    );

    _notesController = TextEditingController(
      text: _currentItem.notes ?? '',
    );

    _selectedCategory = _currentItem.category;
    _selectedLocation = _currentItem.location;
    _selectedUnit = _currentItem.unit;
    _expirationDate = _currentItem.expirationDate;
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    setState(() {
      _expirationDate = pickedDate;
    });
  }

  InventoryItemModel? _findUpdatedItem(List<InventoryItemModel> items) {
    for (final item in items) {
      if (item.id == _currentItem.id) {
        return item;
      }
    }

    return null;
  }

  Future<void> _takePhoto() async {
    if (_isSaving || _isImageUploading || _isImageDeleting) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1200,
    );

    if (pickedImage == null) return;
    if (!mounted) return;

    setState(() {
      _pickedImage = pickedImage;
      _isImageUploading = true;
    });

    context.read<InventoryBloc>().add(
      InventoryItemImageUploadRequested(
        itemId: _currentItem.id,
        imagePath: pickedImage.path,
      ),
    );
  }

  void _deletePhoto() {
    if (_isSaving || _isImageUploading || _isImageDeleting) return;

    setState(() {
      _isImageDeleting = true;
    });

    context.read<InventoryBloc>().add(
      InventoryItemImageDeleteRequested(
        itemId: _currentItem.id,
      ),
    );
  }

  void _saveChanges() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('Please enter valid amount');
      return;
    }

    setState(() => _isSaving = true);

    context.read<InventoryBloc>().add(
      InventoryItemUpdateRequested(
        itemId: _currentItem.id,
        data: InventoryItemUpdateModel(
          customName: _cleanOptionalText(_customNameController.text),
          category: _selectedCategory,
          notes: _cleanOptionalText(_notesController.text),
          location: _selectedLocation,
          amount: amount,
          unit: _selectedUnit,
          expirationDate: _expirationDate,
        ),
      ),
    );
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

  bool get _isBusy {
    return _isSaving || _isImageUploading || _isImageDeleting;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (!_isSaving && !_isImageUploading && !_isImageDeleting) return;

        if (state is InventoryLoadSuccess) {
          final updatedItem = _findUpdatedItem(state.items);

          if (_isImageUploading || _isImageDeleting) {
            setState(() {
              _isImageUploading = false;
              _isImageDeleting = false;
              _pickedImage = null;

              if (updatedItem != null) {
                _currentItem = updatedItem;
              }
            });

            return;
          }

          if (_isSaving) {
            setState(() {
              _isSaving = false;

              if (updatedItem != null) {
                _currentItem = updatedItem;
              }
            });

            context.router.maybePop(
              updatedItem ?? _currentItem,
            );

            return;
          }
        }

        if (state is InventoryFailure) {
          setState(() {
            _isSaving = false;
            _isImageUploading = false;
            _isImageDeleting = false;
            _pickedImage = null;
          });

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
                  onBack: () {
                    if (_isBusy) return;
                    context.router.maybePop(_currentItem);
                  },
                  onSave: _isBusy ? null : _saveChanges,
                  isSaving: _isSaving,
                ),
                const SizedBox(height: 24),
                _ProductImagePicker(
                  category: _selectedCategory,
                  imageUrl: _pickedImage == null
                      ? _bestImageUrlForItem(_currentItem)
                      : null,
                  localImagePath: _pickedImage?.path,
                  isUploading: _isImageUploading || _isImageDeleting,
                  onTakePhoto: _takePhoto,
                  onDeletePhoto: _currentItem.itemImageUrl == null ||
                      _currentItem.itemImageUrl!.isEmpty
                      ? null
                      : _deletePhoto,
                ),
                const SizedBox(height: 26),
                _FormCard(
                  children: [
                    _TextInput(
                      controller: _customNameController,
                      label: 'Product name',
                      icon: Icons.shopping_bag_outlined,
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.length > 150) {
                          return 'Maximum 150 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
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
                    _DropdownInput(
                      label: 'Category',
                      icon: Icons.category_outlined,
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
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
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.chevron_left,
          onTap: onBack,
        ),
        const Expanded(
          child: Text(
            'Edit Product Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2147),
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
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.categoryActiveFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const Padding(
          padding: EdgeInsets.all(11),
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppColors.bottomNavigationBar,
          ),
        )
            : Icon(
          icon,
          color: AppColors.bottomNavigationBar,
          size: 24,
        ),
      ),
    );
  }
}

class _ProductImagePicker extends StatelessWidget {
  final String category;
  final String? imageUrl;
  final String? localImagePath;
  final bool isUploading;
  final VoidCallback onTakePhoto;
  final VoidCallback? onDeletePhoto;

  const _ProductImagePicker({
    required this.category,
    required this.imageUrl,
    required this.localImagePath,
    required this.isUploading,
    required this.onTakePhoto,
    required this.onDeletePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = localImagePath != null && localImagePath!.isNotEmpty;
    final hasNetworkImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasImage = hasLocalImage || hasNetworkImage;

    return Column(
      children: [
        Center(
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasLocalImage)
                  Image.file(
                    File(localImagePath!),
                    fit: BoxFit.cover,
                  )
                else if (hasNetworkImage)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _CategoryIcon(category: category);
                    },
                  )
                else
                  _CategoryIcon(category: category),
                if (isUploading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: isUploading ? null : onTakePhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(hasImage ? 'Retake photo' : 'Take photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bottomNavigationBar,
                    side: const BorderSide(
                      color: AppColors.categoryActiveBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            if (onDeletePhoto != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: isUploading ? null : onDeletePhoto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.expiredBorder,
                    side: const BorderSide(
                      color: AppColors.expiredBorder,
                    ),
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
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconForCategory(category),
      size: 78,
      color: AppColors.bottomNavigationBar,
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({
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
  final DateTime selectedDate;
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
          label: 'Expiration date',
          icon: Icons.calendar_month_outlined,
        ),
        child: Text(
          _formatDate(selectedDate),
          style: const TextStyle(
            color: AppColors.textDark,
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

String? _bestImageUrlForItem(InventoryItemModel item) {
  if (item.itemImageUrl != null && item.itemImageUrl!.isNotEmpty) {
    return ApiConstants.resolveImageUrl(item.itemImageUrl);
  }

  if (item.productImageUrl != null && item.productImageUrl!.isNotEmpty) {
    return ApiConstants.resolveImageUrl(item.productImageUrl);
  }

  return null;
}

String _formatAmountForInput(double amount) {
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