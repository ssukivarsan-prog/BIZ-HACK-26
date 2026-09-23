import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_translations.dart';
import '../../providers/locale_provider.dart';
import '../widgets/my_pre_bookings_sheet.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

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
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.accentOrange.withOpacity(0.15),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentOrange,
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
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Customer'.tr(ref),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppTheme.textGrey, size: 20),
                    title: Text('Email'.tr(ref), style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins')),
                    subtitle: Text(user?.email ?? '', style: AppTextStyles.body),
                  ),
                  const Divider(height: 1, color: AppTheme.dividerColor),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppTheme.textGrey, size: 20),
                    title: Text('Phone'.tr(ref), style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontFamily: 'Poppins')),
                    subtitle: Text(user?.phone ?? '', style: AppTextStyles.body),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: ListTile(
                leading: const Icon(Icons.bookmark_outline_rounded, color: AppTheme.primaryGreen, size: 20),
                title: const Text(
                  'My Pre-Bookings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                subtitle: const Text(
                  'View status of your advance booking requests',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontFamily: 'Poppins',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey),
                onTap: () => MyPreBookingsSheet.show(context),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: SwitchListTile.adaptive(
                title: Text('Language / மொழி'.tr(ref), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                subtitle: Text(locale == 'en' ? 'English' : 'தமிழ்', style: AppTextStyles.caption),
                value: locale == 'ta',
                activeColor: AppTheme.primaryGreen,
                onChanged: (isTamil) {
                  ref.read(localeProvider.notifier).setLocale(isTamil ? 'ta' : 'en');
                },
                secondary: const Icon(Icons.language_rounded, color: AppTheme.primaryGreen, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: ListTile(
                onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/auth/login');
                },
                leading: const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 20),
                title: Text(
                  'Log Out'.tr(ref),
                  style: const TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.errorRed),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Error'.tr(ref))),
      ),
    );
  }
}
