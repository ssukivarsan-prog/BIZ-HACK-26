import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/vegetable_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';
import '../../providers/locale_provider.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Profile'.tr(ref))),
      body: userAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? '', style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Vendor'.tr(ref),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info
            _SectionCard(
              children: [
                _InfoTile(icon: Icons.email_outlined, label: 'Email'.tr(ref), value: user?.email ?? ''),
                const Divider(height: 1, color: AppTheme.dividerColor),
                _InfoTile(icon: Icons.phone_outlined, label: 'Phone'.tr(ref), value: user?.phone ?? ''),
              ],
            ),
            const SizedBox(height: 16),

            // Language Toggle
            _SectionCard(
              children: [
                SwitchListTile.adaptive(
                  title: Text('Language / மொழி'.tr(ref), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  subtitle: Text(locale == 'en' ? 'English' : 'தமிழ்', style: AppTextStyles.caption),
                  value: locale == 'ta',
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (isTamil) {
                    ref.read(localeProvider.notifier).setLocale(isTamil ? 'ta' : 'en');
                  },
                  secondary: const Icon(Icons.language_rounded, color: AppTheme.primaryGreen, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            _SectionCard(
              children: [
                _ActionTile(
                  icon: Icons.refresh_rounded,
                  label: 'Reset Daily Inventory'.tr(ref),
                  color: AppTheme.accentOrange,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Reset Inventory'.tr(ref), style: AppTextStyles.heading3),
                        content: Text(
                          'This will mark all vegetables as available. Continue?'.tr(ref),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr(ref))),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Reset'.tr(ref))),
                        ],
                      ),
                    );
                    if (confirmed == true && user != null) {
                      await ref.read(vegetableServiceProvider).resetDailyInventory(user.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Inventory reset successfully!'.tr(ref))),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1, color: AppTheme.dividerColor),
                _ActionTile(
                  icon: Icons.logout_rounded,
                  label: 'Log Out'.tr(ref),
                  color: AppTheme.errorRed,
                  onTap: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) context.go('/auth/login');
                  },
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error'.tr(ref))),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textGrey, size: 20),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(value, style: AppTextStyles.body),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
    );
  }
}
