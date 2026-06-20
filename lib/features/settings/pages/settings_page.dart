import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/core/global.dart';
import 'package:shopease/features/theme/cubit/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Appearance', colorScheme),
          const SizedBox(height: 8),
          Card(
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;
                return ListTile(
                  leading: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey<bool>(isDark),
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: customisedStyle(
                      colorScheme.onSurfaceVariant,
                      FontWeight.w500,
                      14.0,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? 'Dark theme enabled' : 'Light theme enabled',

                    style: customisedStyle(
                      colorScheme.onSurfaceVariant,
                      FontWeight.w500,
                      12.0,
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: isDark,
                    onChanged: (_) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    activeColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: customisedStyle(colorScheme.primary, FontWeight.w700, 12.0),
      ),
    );
  }
}
