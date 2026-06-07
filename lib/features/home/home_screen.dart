import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../bloc/inventory/inventory.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    context.read<InventoryBloc>().add(
      const InventoryLoadRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoadInProgress) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is InventoryFailure) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is InventoryLoadSuccess) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'FoodTrack',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Fresh: ${state.stats.freshCount}'),
                  Text('Expired: ${state.stats.expiredCount}'),
                  Text(
                    'Expiring tomorrow: ${state.stats.expiringTomorrowCount}',
                  ),
                  Text(
                    'Expiring in 5 days: ${state.stats.expiringInFiveDaysCount}',
                  ),
                  const SizedBox(height: 24),
                  Text('Items: ${state.items.length}'),
                  const SizedBox(height: 12),
                  for (final item in state.items)
                    Card(
                      child: ListTile(
                        title: Text(item.displayName),
                        subtitle: Text(
                          '${item.amount} ${item.unit} • ${item.expiryState}',
                        ),
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}