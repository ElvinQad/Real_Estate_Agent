import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onMaterial3Toggle;
  final bool isDarkMode;
  final bool useMaterial3;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onMaterial3Toggle,
    required this.useMaterial3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              isDarkMode ? 'Using dark theme' : 'Using light theme',
              style: theme.textTheme.bodySmall,
            ),
            value: isDarkMode,
            onChanged: (_) => onThemeToggle(),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.style,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Material 3'),
            subtitle: Text(
              useMaterial3 ? 'Using Material 3' : 'Using Material 2',
              style: theme.textTheme.bodySmall,
            ),
            value: useMaterial3,
            onChanged: (_) => onMaterial3Toggle(),
          ),
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
