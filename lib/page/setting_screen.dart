import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/Auth_screens/accounAnalyz.dart';
import 'package:flutter_course_2/providers/theme_notifier.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/utailates/dialogs/logout_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _user = AuthService.firebase().currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionHeader('Account'),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Account Settings',
              subtitle: _user?.email ?? 'No email found',
              onTap: () {
                // TODO: Navigate to Account Settings page
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildThemeSettingsTile(context),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Learn more about the app',
              onTap: () async {
                final Uri url = Uri.parse('https://github.com/Kerollosmm/Notely_Flutter_Course');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            const Divider(height: 48),
            _buildLogoutTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return InkWell(
      onTap: () async {
        final shouldLogout = await showLogOutDialog(context);
        if (shouldLogout) {
          // Dispatch the logout event
          context.read<AuthBloc>().add(const AuthEventLogOut());
          // Navigate to the root and remove all previous screens
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const AccountAnalyze(),
              ),
              (route) => false);
        }
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(Icons.logout, color: Colors.red[700], size: 24),
            ),
            const SizedBox(width: 16.0),
            const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.red[300], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: isDarkMode ? Colors.white : Colors.blue.shade800, size: 24),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingsTile(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return _buildSettingsTile(
      icon: Icons.wb_sunny_outlined,
      title: 'Theme',
      subtitle: "Customize the app's appearance",
      onTap: () {},
      trailing: PopupMenuButton<ThemeMode>(
        onSelected: (ThemeMode mode) {
          themeNotifier.setThemeMode(mode);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
          const PopupMenuItem<ThemeMode>(
            value: ThemeMode.light,
            child: Text('Light'),
          ),
          const PopupMenuItem<ThemeMode>(
            value: ThemeMode.dark,
            child: Text('Dark'),
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              themeNotifier.themeMode.toString().split('.').last,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
