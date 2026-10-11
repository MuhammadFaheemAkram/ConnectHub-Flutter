import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/features/settings/cubit/settings_cubit.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_cubit.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Renders Settings: appearance, badges, language, storage, the developer
/// switches, the account and About.
///
/// Two Cubits feed it. The preferences come from the *app-scoped*
/// [SettingsCubit] above `MaterialApp`, so choosing Dark here restyles the
/// whole app at once. The actions (clear cache, the developer switches) come
/// from the screen's own [SettingsToolsCubit].
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.appVersion,
    required this.onLogout,
  });

  /// For example `1.0.0 (1)`.
  final String appVersion;

  /// Called once the user has confirmed.
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Settings'),
      ),
      body: BlocListener<SettingsToolsCubit, SettingsToolsState>(
        listenWhen: (previous, current) =>
            current.message != null && current.message != previous.message,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!.text)));
        },
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (context, settings) => ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
            children: [
              const _SectionHeader('Appearance'),
              _ThemeModePicker(selected: settings.themeMode),
              const SizedBox(height: AppSpacing.medium),
              const _SectionHeader('Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Show unread badges'),
                subtitle: const Text('On the Activity tab and on Chats.'),
                value: settings.notificationsEnabled,
                onChanged: (enabled) => context
                    .read<SettingsCubit>()
                    .setNotificationsEnabled(enabled: enabled),
              ),
              const SizedBox(height: AppSpacing.small),
              const _SectionHeader('Language'),
              _LanguagePicker(selected: settings.language),
              const SizedBox(height: AppSpacing.medium),
              const _SectionHeader('Storage'),
              const _ClearCacheTile(),
              const SizedBox(height: AppSpacing.small),
              const _SectionHeader('Developer'),
              const _DeveloperTiles(),
              const SizedBox(height: AppSpacing.small),
              const _SectionHeader('Account'),
              _LogoutTile(onLogout: onLogout),
              const SizedBox(height: AppSpacing.small),
              const _SectionHeader('About'),
              _About(appVersion: appVersion),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.selected});

  final AppThemeMode selected;

  static const _choices = [
    (AppThemeMode.system, 'System', Icons.brightness_auto_outlined),
    (AppThemeMode.light, 'Light', Icons.light_mode_outlined),
    (AppThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    // Three segments share a phone's width. With large text, "System" would
    // break mid-word inside its segment, so the choices become a list.
    if (context.prefersStackedLayout) {
      return RadioGroup<AppThemeMode>(
        groupValue: selected,
        onChanged: (mode) {
          if (mode != null) cubit.selectThemeMode(mode);
        },
        child: Column(
          children: [
            for (final (mode, label, icon) in _choices)
              RadioListTile<AppThemeMode>(
                value: mode,
                title: Text(label),
                secondary: Icon(icon),
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: SegmentedButton<AppThemeMode>(
        segments: [
          for (final (mode, label, icon) in _choices)
            ButtonSegment(value: mode, icon: Icon(icon), label: Text(label)),
        ],
        selected: {selected},
        onSelectionChanged: (selection) =>
            cubit.selectThemeMode(selection.single),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.selected});

  final AppLanguage selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      child: DropdownMenu<AppLanguage>(
        // Rebuilt when the value changes elsewhere: DropdownMenu only reads
        // `initialSelection` once.
        key: ValueKey(selected),
        initialSelection: selected,
        expandedInsets: EdgeInsets.zero,
        label: const Text('Language'),
        leadingIcon: const Icon(Icons.translate),
        helperText: 'Saved, but a label only: no translations yet.',
        dropdownMenuEntries: [
          for (final language in AppLanguage.values)
            DropdownMenuEntry(value: language, label: language.displayName),
        ],
        onSelected: (language) {
          if (language != null) {
            context.read<SettingsCubit>().selectLanguage(language);
          }
        },
      ),
    );
  }
}

class _ClearCacheTile extends StatelessWidget {
  const _ClearCacheTile();

  @override
  Widget build(BuildContext context) {
    final isClearing = context.select(
      (SettingsToolsCubit cubit) => cubit.state.isClearingCache,
    );
    return ListTile(
      leading: const Icon(Icons.cleaning_services_outlined),
      title: const Text('Clear cache'),
      subtitle: const Text(
        'Posts, profiles, chats and notifications download again. '
        'Bookmarks stay.',
      ),
      trailing: isClearing
          ? const ButtonProgress(semanticsLabel: 'Clearing the cache')
          : null,
      onTap: isClearing ? null : () => _confirm(context),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<SettingsToolsCubit>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Clear cache?',
      message:
          'Cached posts, profiles, chats and notifications are deleted, and '
          'download again when you need them. Bookmarks, recent searches and '
          'unsent messages stay.',
      confirmLabel: 'Clear',
      isDestructive: true,
    );
    if (confirmed) await cubit.clearCache();
  }
}

class _DeveloperTiles extends StatelessWidget {
  const _DeveloperTiles();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsToolsCubit>();
    final failsRequests = context.select(
      (SettingsToolsCubit cubit) => cubit.state.failsRequests,
    );
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.wifi_off_outlined),
          title: const Text('Simulate network failure'),
          subtitle: const Text(
            'Every request fails, as if offline. Resets when the app '
            'restarts.',
          ),
          value: failsRequests,
          onChanged: (fail) => cubit.setNetworkFailure(fail: fail),
        ),
        ListTile(
          leading: const Icon(Icons.timer_off_outlined),
          title: const Text('Expire session'),
          subtitle: const Text(
            'The server refuses the next request, which signs you out.',
          ),
          onTap: cubit.expireSession,
        ),
      ],
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return ListTile(
      leading: Icon(Icons.logout, color: error),
      title: Text('Log out', style: TextStyle(color: error)),
      onTap: () async {
        final confirmed = await showConfirmationDialog(
          context,
          title: 'Log out?',
          message: "You'll need to sign in again to use ConnectHub.",
          confirmLabel: 'Log out',
        );
        if (confirmed) onLogout();
      },
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.appVersion});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.hub_outlined),
          title: const Text('ConnectHub'),
          subtitle: Text('Version $appVersion'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Text(
            'A learning-focused Flutter app: an offline-first social feed '
            'with chat, built with Bloc, drift and go_router on a fake '
            'backend.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: 'ConnectHub',
          applicationVersion: appVersion,
          applicationLegalese: '© 2026 BitFuse · MIT License',
          child: const Text('Licenses'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.xSmall,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
