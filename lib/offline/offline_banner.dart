import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../offline/offline_cache_service.dart';
import '../theme/app_theme.dart';

/// Drop this widget at the top of any screen body to show a network banner
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFFFF3E0),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: AppTheme.accentOrange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline — showing cached data',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.accentOrange,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -1, duration: 300.ms, curve: Curves.easeOut);
  }
}
