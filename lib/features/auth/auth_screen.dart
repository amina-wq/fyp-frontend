import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth.dart';
import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;

  void _toggleForm(bool isSignUp) {
    setState(() {
      _isSignUp = isSignUp;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('FoodTrack'),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthState,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Text(
                  _isSignUp ? 'Create your account' : 'Welcome back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isSignUp
                      ? 'Register to start tracking your food expiry dates.'
                      : 'Sign in to continue managing your food inventory.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AuthModeButton(
                          label: 'Sign In',
                          isSelected: !_isSignUp,
                          onTap: () => _toggleForm(false),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _AuthModeButton(
                          label: 'Sign Up',
                          isSelected: _isSignUp,
                          onTap: () => _toggleForm(true),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              context,
                              label: 'Name',
                              icon: Icons.person_outline_rounded,
                            ),
                            style: TextStyle(color: colors.textPrimary),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your name';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration(
                            context,
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          style: TextStyle(color: colors.textPrimary),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          decoration: _inputDecoration(
                            context,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                          ),
                          style: TextStyle(color: colors.textPrimary),
                          obscureText: true,
                          validator: (value) {
                            final password = value ?? '';

                            if (password.length < 8) {
                              return 'Password must be at least 8 characters';
                            }

                            if (!RegExp(r'[A-Z]').hasMatch(password)) {
                              return 'Password must contain one uppercase letter';
                            }

                            if (!RegExp(r'[a-z]').hasMatch(password)) {
                              return 'Password must contain one lowercase letter';
                            }

                            if (!RegExp(r'[0-9]').hasMatch(password)) {
                              return 'Password must contain one number';
                            }

                            if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
                              return 'Password must contain one special character';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return SizedBox(
                                height: 52,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colors.primary,
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.textOnPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  _isSignUp ? 'Create Account' : 'Sign In',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colors = context.appColors;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.textMuted),
      prefixIcon: Icon(icon, color: colors.textMuted),
      filled: true,
      fillColor: colors.surfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.danger, width: 1.4),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthFailure) {
      final colors = context.appColors;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colors.dangerSoft,
          content: Text(
            state.message,
            style: TextStyle(color: colors.textPrimary),
          ),
        ),
      );
    }

    if (state is AuthAuthenticated) {
      context.router.replace(const HomeRoute());
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authBloc = context.read<AuthBloc>();

    if (_isSignUp) {
      authBloc.add(
        AuthRegisterRequested(name: name, email: email, password: password),
      );
    } else {
      authBloc.add(AuthLoginRequested(email: email, password: password));
    }
  }
}

class _AuthModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AuthModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isSelected
              ? colors.textOnPrimary
              : colors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
