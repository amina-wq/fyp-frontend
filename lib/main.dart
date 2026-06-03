import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'repositories/auth/auth_repository.dart';
import 'repositories/auth/auth_repository_interface.dart';
import 'router/router.dart';
import 'ui/ui.dart';

void main() {
  final apiClient = ApiClient();
  final tokenStorage = TokenStorage();

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final appRouter = AppRouter(
    authRepository: authRepository,
  );

  runApp(
    FoodTrackApp(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      appRouter: appRouter,
    ),
  );
}

class FoodTrackApp extends StatelessWidget {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final AuthRepositoryInterface authRepository;
  final AppRouter appRouter;

  const FoodTrackApp({
    super.key,
    required this.apiClient,
    required this.tokenStorage,
    required this.authRepository,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(
          value: apiClient,
        ),
        RepositoryProvider<TokenStorage>.value(
          value: tokenStorage,
        ),
        RepositoryProvider<AuthRepositoryInterface>.value(
          value: authRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryInterface>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'FoodTrack',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          routerConfig: appRouter.config(),
        ),
      ),
    );
  }
}