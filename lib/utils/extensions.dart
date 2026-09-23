import 'package:intl/intl.dart';

// ─── DateTime Extensions ──────────────────────────────────────────────────────
extension DateTimeX on DateTime {
  String get displayDate => DateFormat('dd MMM yyyy').format(this);
  String get displayDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  String get displayTime => DateFormat('hh:mm a').format(this);
  String get displayDay => DateFormat('EEE, dd MMM').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get relativeDisplay {
    if (isToday) return 'Today, $displayTime';
    if (isYesterday) return 'Yesterday, $displayTime';
    return displayDateTime;
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return displayDate;
  }
}

// ─── Double / Currency Extensions ────────────────────────────────────────────
extension DoubleX on double {
  /// Format as Indian Rupees: ₹1,234.50
  String get inr {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  /// Short rupee display without decimal for round numbers: ₹40
  String get inrShort {
    if (this == truncateToDouble()) {
      return '₹${toInt()}';
    }
    return '₹${toStringAsFixed(2)}';
  }

  /// Clamp to 2 decimal places
  double get rounded2 => double.parse(toStringAsFixed(2));
}

// ─── String Extensions ────────────────────────────────────────────────────────
extension StringX on String {
  /// Capitalise first letter of each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Returns true if this looks like a valid email
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Returns true if this is a valid Indian mobile number
  bool get isValidPhone =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(replaceAll(RegExp(r'\s+'), ''));

  /// Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// First N characters of a name as initials, e.g. "John Doe" → "JD"
  String get initials {
    final parts = trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ─── List Extensions ──────────────────────────────────────────────────────────
extension ListX<T> on List<T> {
  /// Safe first element; returns null if list is empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Safe last element; returns null if list is empty
  T? get lastOrNull => isEmpty ? null : last;
}
