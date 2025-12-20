import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/constants/app_colors.dart';
import 'package:flutter_course_2/constants/app_dimensions.dart';
import 'package:flutter_course_2/services/auth/auth_service.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:provider/provider.dart';
import 'package:flutter_course_2/providers/theme_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = AuthService.firebase().currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _profileImagePath = prefs.getString('profile_image_${user.id}');
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final user = AuthService.firebase().currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${user.id}', image.path);
        setState(() {
          _profileImagePath = image.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const CloseButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'ACCOUNT'),
            _buildAccountCard(context, user),
            SizedBox(height: AppDimensions.paddingL),

            _buildSectionHeader(context, 'GENERAL'),
            _buildListTile(context, icon: Icons.notifications_outlined, title: 'Notifications'),
            _buildListTile(context, icon: Icons.cloud_sync_outlined, title: 'Sync & Backup', trailingText: 'Just now'),
            _buildListTile(context, icon: Icons.lock_outline, title: 'Privacy & Security'),
            SizedBox(height: AppDimensions.paddingL),

            _buildSectionHeader(context, 'APPEARANCE'),
            _buildListTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Consumer<ThemeNotifier>(
                builder: (context, notifier, _) => Switch(
                  value: notifier.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    notifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  }
                ),
              ),
            ),
            _buildListTile(context, icon: Icons.text_fields, title: 'Text Size', trailingText: 'Medium'),
             SizedBox(height: AppDimensions.paddingL),

            _buildSectionHeader(context, 'ABOUT'),
            _buildListTile(context, icon: Icons.help_outline, title: 'Help & Support'),
            _buildListTile(context, icon: Icons.info_outline, title: 'Version', trailingText: '1.0.0'),
            SizedBox(height: AppDimensions.paddingXL),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                   final shouldLogout = await showDialog<bool>(
                     context: context,
                     builder: (context) => AlertDialog(
                       title: const Text('Log Out'),
                       content: const Text('Are you sure you want to log out?'),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                         TextButton(
                           onPressed: () => Navigator.pop(context, true),
                           child: const Text('Log Out', style: TextStyle(color: Colors.red))
                         ),
                       ],
                     ),
                   );

                   if (shouldLogout == true) {
                      // Trigger security fix in AuthBloc
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                      // Clear navigation stack
                      Navigator.of(context).popUntil((route) => route.isFirst);
                   }
                },
                child: Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 16.sp)),
              ),
            ),
             SizedBox(height: AppDimensions.paddingM),
             Center(child: Text('Notely App © 2024', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AuthUser? user) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.primary,
              backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
              child: _profileImagePath == null
                  ? Text(
                      user?.email.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(user?.email ?? 'No Email', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: const Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.textPrimaryLight, size: 20.sp),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing ?? (trailingText != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trailingText, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              SizedBox(width: 8.w),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          )
        : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
      ),
      onTap: () {},
    );
  }
}
