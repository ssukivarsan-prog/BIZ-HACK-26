import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Generic confirmation dialog.
/// Returns true if confirmed, false/null if dismissed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDanger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(title, style: AppTextStyles.heading3),
      content: Text(message, style: AppTextStyles.subtitle),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(80, 42),
          ),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppTheme.errorRed : AppTheme.primaryGreen,
            minimumSize: const Size(80, 42),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Quick info bottom sheet — not a question, just informational.
Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required String body,
  IconData icon = Icons.info_outline_rounded,
  Color iconColor = AppTheme.primaryGreen,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: iconColor),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.heading3, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(body, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Snackbar helpers
extension SnackBarX on BuildContext {
  void showSuccess(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  void showInfo(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
