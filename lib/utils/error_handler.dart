import 'package:firebase_auth/firebase_auth.dart';
import 'logger.dart';

class AppError {
  final String message;
  final bool isRetryable;

  const AppError(this.message, {this.isRetryable = false});

  @override
  String toString() => message;
}

class ErrorHandler {
  ErrorHandler._();

  static AppError handle(Object error, {String? context}) {
    AppLogger.error('[${context ?? 'App'}] $error');

    if (error is FirebaseAuthException) {
      return AppError(_authMessage(error.code));
    }

    if (error is FirebaseException) {
      return AppError(_firestoreMessage(error.code), isRetryable: true);
    }

    if (error is AppError) return error;

    final msg = error.toString();
    if (msg.contains('network') || msg.contains('connection')) {
      return const AppError(
        'Network error. Please check your connection.',
        isRetryable: true,
      );
    }

    return const AppError('Something went wrong. Please try again.', isRetryable: true);
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to continue.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  static String _firestoreMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to do that.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'resource-exhausted':
        return 'Service temporarily unavailable. Please try again.';
      case 'unavailable':
        return 'Service unavailable. Please check your connection.';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again.';
      default:
        return 'Database error. Please try again.';
    }
  }
}
