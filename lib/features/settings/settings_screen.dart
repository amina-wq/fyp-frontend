import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth.dart';
import '../../models/auth/auth.dart';
import '../../ui/theme/app_colors.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AuthBloc>().state;

      if (state is AuthInitial || state is AuthUnauthenticated) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is AuthUnauthenticated) {
          context.router.replacePath('/auth');
        }
      },
      builder: (context, state) {
        final user = _userFromState(state);
        final isLoading = state is AuthLoading;
        final isActionInProgress = state is AuthActionInProgress;

        if (isLoading || user == null) {
          return Scaffold(
            backgroundColor: colors.background,
            body: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                const _SettingsHeader(),
                const SizedBox(height: 22),
                _ProfileCard(
                  user: user,
                  isActionInProgress: isActionInProgress,
                  onEditName: () => _showEditNameDialog(
                    context: context,
                    currentName: user.name,
                  ),
                ),
                const SizedBox(height: 18),
                _NotificationSettingsCard(
                  user: user,
                  isActionInProgress: isActionInProgress,
                ),
                const SizedBox(height: 18),
                _ThemeSettingsCard(
                  user: user,
                  isActionInProgress: isActionInProgress,
                ),
                const SizedBox(height: 18),
                _LogoutCard(isActionInProgress: isActionInProgress),
              ],
            ),
          ),
        );
      },
    );
  }

  UserModel? _userFromState(AuthState state) {
    if (state is AuthAuthenticated) {
      return state.user;
    }

    if (state is AuthActionInProgress) {
      return state.user;
    }

    return null;
  }

  Future<void> _showEditNameDialog({
    required BuildContext context,
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.appColors;

        return AlertDialog(
          backgroundColor: dialogColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit name',
            style: TextStyle(
              color: dialogColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              color: dialogColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: dialogColors.surfaceSoft,
              hintStyle: TextStyle(
                color: dialogColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: dialogColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: dialogColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: dialogColors.primary, width: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dialogColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogColors.primary,
                foregroundColor: dialogColors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null) return;
    if (newName.isEmpty) return;
    if (newName == currentName) return;
    if (!context.mounted) return;

    context.read<AuthBloc>().add(AuthNameUpdateRequested(name: newName));
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      'Settings',
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserModel user;
  final bool isActionInProgress;
  final VoidCallback onEditName;

  const _ProfileCard({
    required this.user,
    required this.isActionInProgress,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return _SettingsCard(
      title: 'Profile',
      children: [
        _InfoRow(
          icon: Icons.person_outline,
          title: 'Name',
          value: user.name,
          trailing: IconButton(
            onPressed: isActionInProgress ? null : onEditName,
            icon: Icon(Icons.edit_outlined, color: colors.primary),
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.email_outlined, title: 'Email', value: user.email),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.verified_user_outlined,
          title: 'Account type',
          value: _formatText(user.accountType),
        ),
      ],
    );
  }
}

class _NotificationSettingsCard extends StatelessWidget {
  final UserModel user;
  final bool isActionInProgress;

  const _NotificationSettingsCard({
    required this.user,
    required this.isActionInProgress,
  });

  static const List<int> _availableDays = [0, 1, 3, 5, 7];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return _SettingsCard(
      title: 'Expiry Notifications',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: user.expiryNotificationsEnabled,
          activeColor: colors.primary,
          title: Text(
            'Enable notifications',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            'Receive reminders before food expires.',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: isActionInProgress
              ? null
              : (value) {
                  _updateSettings(
                    context: context,
                    user: user,
                    expiryNotificationsEnabled: value,
                  );
                },
        ),
        const SizedBox(height: 12),
        Text(
          'Warning days before expiry',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableDays.map((day) {
            final isSelected = user.notificationDaysBefore.contains(day);

            return FilterChip(
              selected: isSelected,
              label: Text(_labelForDay(day)),
              selectedColor: colors.chipSelected,
              backgroundColor: colors.chipUnselected,
              checkmarkColor: colors.primary,
              side: BorderSide(
                color: isSelected
                    ? colors.chipSelectedBorder
                    : colors.chipUnselectedBorder,
              ),
              labelStyle: TextStyle(
                color: isSelected ? colors.primary : colors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
              onSelected: isActionInProgress
                  ? null
                  : (selected) {
                      final updatedDays = List<int>.from(
                        user.notificationDaysBefore,
                      );

                      if (selected) {
                        updatedDays.add(day);
                      } else {
                        if (updatedDays.length == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Select at least one reminder day.',
                              ),
                              backgroundColor: context.appColors.warningSoft,
                            ),
                          );

                          return;
                        }

                        updatedDays.remove(day);
                      }

                      updatedDays.sort((a, b) => b.compareTo(a));

                      _updateSettings(
                        context: context,
                        user: user,
                        notificationDaysBefore: updatedDays,
                      );
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _updateSettings({
    required BuildContext context,
    required UserModel user,
    List<int>? notificationDaysBefore,
    bool? expiryNotificationsEnabled,
    String? themeMode,
  }) {
    context.read<AuthBloc>().add(
      AuthSettingsUpdateRequested(
        notificationDaysBefore:
            notificationDaysBefore ?? user.notificationDaysBefore,
        expiryNotificationsEnabled:
            expiryNotificationsEnabled ?? user.expiryNotificationsEnabled,
        themeMode: themeMode ?? user.themeMode,
      ),
    );
  }

  String _labelForDay(int day) {
    if (day == 0) {
      return 'On expiry day';
    }

    if (day == 1) {
      return '1 day before';
    }

    return '$day days before';
  }
}

class _ThemeSettingsCard extends StatelessWidget {
  final UserModel user;
  final bool isActionInProgress;

  const _ThemeSettingsCard({
    required this.user,
    required this.isActionInProgress,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Appearance',
      children: [
        _ThemeOption(
          title: 'System',
          value: 'system',
          groupValue: user.themeMode,
          isDisabled: isActionInProgress,
          onChanged: (value) =>
              _updateThemeMode(context: context, user: user, themeMode: value),
        ),
        _ThemeOption(
          title: 'Light',
          value: 'light',
          groupValue: user.themeMode,
          isDisabled: isActionInProgress,
          onChanged: (value) =>
              _updateThemeMode(context: context, user: user, themeMode: value),
        ),
        _ThemeOption(
          title: 'Dark',
          value: 'dark',
          groupValue: user.themeMode,
          isDisabled: isActionInProgress,
          onChanged: (value) =>
              _updateThemeMode(context: context, user: user, themeMode: value),
        ),
      ],
    );
  }

  void _updateThemeMode({
    required BuildContext context,
    required UserModel user,
    required String themeMode,
  }) {
    if (themeMode == user.themeMode) return;

    context.read<AuthBloc>().add(
      AuthSettingsUpdateRequested(
        notificationDaysBefore: user.notificationDaysBefore,
        expiryNotificationsEnabled: user.expiryNotificationsEnabled,
        themeMode: themeMode,
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final bool isActionInProgress;

  const _LogoutCard({required this.isActionInProgress});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isActionInProgress
            ? null
            : () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
        icon: const Icon(Icons.logout_outlined),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.danger,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.surfaceSoft,
          disabledForegroundColor: colors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final bool isDisabled;
  final ValueChanged<String> onChanged;

  const _ThemeOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: groupValue,
      activeColor: colors.primary,
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      onChanged: isDisabled
          ? null
          : (selectedValue) {
              if (selectedValue == null) return;
              onChanged(selectedValue);
            },
    );
  }
}

String _formatText(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      })
      .join(' ');
}
