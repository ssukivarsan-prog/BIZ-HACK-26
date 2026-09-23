import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void info(String message) => _logger.i(message);
  static void error(String message) => _logger.e(message);
  static void warning(String message) => _logger.w(message);
  static void debug(String message) => _logger.d(message);
}
