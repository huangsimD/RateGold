import 'dart:io';

/// Copies integration-test screenshots into store/play/screenshots/.
/// Run after: flutter test integration_test/store_screenshots_test.dart -d <device>
void main() {
  final root = Directory.current;
  final src = Directory('${root.path}/build/integration_test_screenshots');
  if (!src.existsSync()) {
    stderr.writeln('Missing ${src.path} — run integration_test first.');
    exit(1);
  }

  final dest = Directory('${root.path}/store/play/screenshots');
  dest.createSync(recursive: true);

  const names = [
    '01_board',
    '02_convert',
    '03_settings',
    '04_gold_markets',
  ];

  var copied = 0;
  for (final name in names) {
    for (final ext in ['png', 'jpg']) {
      final file = File('${src.path}/$name.$ext');
      if (file.existsSync()) {
        final out = File('${dest.path}/$name.png');
        out.writeAsBytesSync(file.readAsBytesSync());
        stdout.writeln('Wrote ${out.path}');
        copied++;
        break;
      }
    }
  }

  if (copied == 0) {
    stderr.writeln('No screenshots found in ${src.path}');
    exit(1);
  }

  stdout.writeln('Collected $copied screenshot(s) → store/play/screenshots/');
}
