import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/auth.dart';
import '../../../router/router.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.router.replace(const AuthRoute());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FoodTrack'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthLogoutRequested(),
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Center(
          child: Text('Home screen will be here'),
        ),
      ),
    );
  }
}