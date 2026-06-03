import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth.dart';
import 'auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return Scaffold(
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
            body: Center(
              child: Text('Welcome, ${state.user.name}'),
            ),
          );
        }

        return const AuthScreen();
      },
    );
  }
}