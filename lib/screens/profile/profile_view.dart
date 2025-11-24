import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '/screens/profile/widgets.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // --- STATE VARIABLES ---
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Alex Johnson');
  final _emailController = TextEditingController(text: 'alex@example.com');
  final _goalController = TextEditingController(text: '5');

  bool _pushNotifications = true;
  bool _weeklyReports = false;
  bool _isDarkMode = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // --- LOGIC FUNCTIONS ---
  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile & Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your account and preferences',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- MAIN CONTENT AREA ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- SECTION: PROFILE FORM ---
                  // Use SectionHeader (public name)
                  const SectionHeader(icon: Icons.person_outline, title: 'Profile'),

                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Avatar Row
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blueAccent,
                                        Colors.purpleAccent.shade100
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'AJ',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nameController.text,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _emailController.text,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),

                            // Use ProfileTextField (public name)
                            ProfileTextField(
                              label: 'Full Name',
                              controller: _nameController,
                            ),
                            const SizedBox(height: 16),
                            ProfileTextField(
                              label: 'Email',
                              controller: _emailController,
                              inputType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            ProfileTextField(
                              label: 'Daily Habit Goal',
                              controller: _goalController,
                              inputType: TextInputType.number,
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _saveProfile,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Save Profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION: NOTIFICATIONS ---
                  const SectionHeader(
                      icon: Icons.notifications_outlined, title: 'Notifications'),

                  // Use SettingsCard (public name)
                  SettingsCard(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Receive habit reminders'),
                        value: _pushNotifications,
                        onChanged: (val) => setState(() => _pushNotifications = val),
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Weekly Progress Report'),
                        subtitle: const Text('Get weekly summary emails'),
                        value: _weeklyReports,
                        onChanged: (val) => setState(() => _weeklyReports = val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION: APPEARANCE ---
                  const SectionHeader(icon: Icons.palette_outlined, title: 'Appearance'),
                  SettingsCard(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dark Mode', style: theme.textTheme.titleMedium),
                              Text(
                                'Switch to dark theme',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: theme.hintColor),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.wb_sunny_outlined,
                                  size: 20, color: theme.hintColor),
                              Switch.adaptive(
                                value: _isDarkMode,
                                onChanged: (val) =>
                                    setState(() => _isDarkMode = val),
                              ),
                              Icon(Icons.nightlight_round,
                                  size: 20, color: theme.hintColor),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION: DATA MANAGEMENT ---
                  const SectionHeader(
                      icon: Icons.storage_outlined, title: 'Data Management'),
                  SettingsCard(
                    children: [
                      // Use ActionTile (public name)
                      ActionTile(
                        icon: Icons.download_outlined,
                        title: 'Export All Data',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      ActionTile(
                        icon: Icons.delete_outline,
                        title: 'Clear All Data',
                        textColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
