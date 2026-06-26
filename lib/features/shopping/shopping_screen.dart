import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/shopping_list/shopping_list.dart';
import '../../models/shopping_list/shopping_list.dart';

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

    context.read<ShoppingListBloc>().add(
      const ShoppingListLoadRequested(),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    String selectedCategory = 'other';
    String selectedUnit = 'pcs';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add shopping item'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                        hintText: 'Milk',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: '2',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'pcs', child: Text('pcs')),
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'l', child: Text('l')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedUnit = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                        DropdownMenuItem(value: 'dairy', child: Text('Dairy')),
                        DropdownMenuItem(value: 'meat', child: Text('Meat')),
                        DropdownMenuItem(
                          value: 'vegetables',
                          child: Text('Vegetables'),
                        ),
                        DropdownMenuItem(value: 'fruits', child: Text('Fruits')),
                        DropdownMenuItem(value: 'grains', child: Text('Grains')),
                        DropdownMenuItem(value: 'drinks', child: Text('Drinks')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  return;
                }

                final amount = double.tryParse(
                  amountController.text.trim(),
                );

                context.read<ShoppingListBloc>().add(
                  ShoppingListItemCreateRequested(
                    item: ShoppingListItemCreateModel(
                      name: name,
                      category: selectedCategory,
                      amount: amount,
                      unit: selectedUnit,
                    ),
                  ),
                );

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      ShoppingListState state,
      ) {
    if (state is ShoppingListInitial || state is ShoppingListLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ShoppingListFailure) {
      return Center(
        child: Text(state.message),
      );
    }

    if (state is ShoppingListLoaded) {
      if (state.items.isEmpty) {
        return const Center(
          child: Text('Shopping list is empty'),
        );
      }

      return ListView(
        children: [
          if (state.uncheckedItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'To buy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.uncheckedItems.map(
                  (item) => _buildItemTile(context, item),
            ),
          ],
          if (state.checkedItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Checked',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.checkedItems.map(
                  (item) => _buildItemTile(context, item),
            ),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _buildSubtitle(ShoppingListItemModel item) {
    final amount = item.amount;
    final unit = item.unit;

    if (amount == null && unit == null) {
      return item.category;
    }

    if (amount != null && unit != null) {
      return '${_formatAmount(amount)} $unit · ${item.category}';
    }

    if (amount != null) {
      return '${_formatAmount(amount)} · ${item.category}';
    }

    return '$unit · ${item.category}';
  }

  String _formatAmount(double amount) {
    if (amount % 1 == 0) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(1);
  }

  Widget _buildItemTile(
      BuildContext context,
      ShoppingListItemModel item,
      ) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<ShoppingListBloc>().add(
          ShoppingListItemDeleteRequested(
            itemId: item.id,
          ),
        );
      },
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (_) {
          context.read<ShoppingListBloc>().add(
            ShoppingListItemToggleRequested(
              itemId: item.id,
            ),
          );
        },
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(_buildSubtitle(item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingListBloc, ShoppingListState>(
      listener: (context, state) {
        if (state is ShoppingListFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shopping List'),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<ShoppingListBloc>().add(
                    const ShoppingListLoadRequested(),
                  );
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: () {
                  context.read<ShoppingListBloc>().add(
                    const ShoppingListCheckedClearRequested(),
                  );
                },
                icon: const Icon(Icons.cleaning_services_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(context),
            child: const Icon(Icons.add),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }
}