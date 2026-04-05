import 'dart:io';
import 'dart:convert';

void main() {
  // Create assets directory
  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    assetsDir.createSync(recursive: true);
  }

  // Minimal 1x1 dark blue PNG (base64 of valid PNG with color #1A1A2E)
  const base64Png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

  final bytes = base64Decode(base64Png);
  File('assets/splash_logo.png').writeAsBytesSync(bytes);
  print('Created assets/splash_logo.png');
}
