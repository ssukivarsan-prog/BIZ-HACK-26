import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-screen loading overlay — wrap a Stack child to block interaction.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                        strokeWidth: 3,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Inline loading spinner with optional label — for inside cards/lists.
class InlineLoader extends StatelessWidget {
  final String? label;
  final double size;

  const InlineLoader({super.key, this.label, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 12),
          Text(label!, style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textGrey, fontSize: 14)),
        ],
      ],
    );
  }
}

/// Async button that shows a spinner while loading.
class AsyncButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final String? loadingLabel;
  final bool isOutlined;

  const AsyncButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.loadingLabel,
    this.isOutlined = false,
  });

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _loading = false;

  Future<void> _handle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              if (widget.loadingLabel != null) ...[
                const SizedBox(width: 10),
                Text(
                  widget.loadingLabel!,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 15),
                ),
              ],
            ],
          )
        : widget.child;

    if (widget.isOutlined) {
      return OutlinedButton(
        onPressed: _loading ? null : _handle,
        child: content,
      );
    }
    return ElevatedButton(
      onPressed: _loading ? null : _handle,
      child: content,
    );
  }
}
