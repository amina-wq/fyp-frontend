import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/shopping_list/shopping_list.dart';
import '../../models/shopping_list/shopping_list.dart';
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

    context.read<ShoppingListBloc>().add(
      const ShoppingListLoadRequested(),
    );
  }

  Future<void> _openManualAddDialog() async {
    await showAddToShoppingListDialog(
      context: context,
      initialName: '',
      initialCategoryId: null,
      source: 'manual',
      sourceId: null,
      initialAmount: null,
      initialUnit: null,
      allowNameEditing: true,
      allowCategoryEditing: true,
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 56,
                  color: Colors.black38,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Shopping list is empty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _openManualAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add item'),
                ),
              ],
            ),
          ),
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
            centerTitle: false,
            titleSpacing: 20,
            title: const Text('Shopping List'),
            actions: [
              IconButton(
                onPressed: _openManualAddDialog,
                icon: const Icon(Icons.add),
              ),
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
          body: _buildBody(context, state),
        );
      },
    );
  }
}