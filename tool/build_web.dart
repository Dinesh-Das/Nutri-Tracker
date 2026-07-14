import 'dart:convert';
import 'dart:io';

const _firebaseKeys = <String>[
  'FIREBASE_WEB_API_KEY',
  'FIREBASE_WEB_APP_ID',
  'FIREBASE_WEB_MESSAGING_SENDER_ID',
  'FIREBASE_WEB_PROJECT_ID',
  'FIREBASE_WEB_AUTH_DOMAIN',
  'FIREBASE_WEB_STORAGE_BUCKET',
  'FIREBASE_WEB_MEASUREMENT_ID',
];

const _requiredKeys = <String>{
  'FIREBASE_WEB_API_KEY',
  'FIREBASE_WEB_APP_ID',
  'FIREBASE_WEB_MESSAGING_SENDER_ID',
  'FIREBASE_WEB_PROJECT_ID',
};

Future<void> main() async {
  final fileValues = await _readLocalConfig();
  if (fileValues == null) return;
  final values = <String, String>{};

  for (final key in _firebaseKeys) {
    final environmentValue = Platform.environment[key]?.trim() ?? '';
    final fileValue = fileValues[key]?.trim() ?? '';
    final value = environmentValue.isNotEmpty ? environmentValue : fileValue;
    if (value.isNotEmpty) values[key] = value;
  }

  final missing =
      _requiredKeys.where((key) => !values.containsKey(key)).toList()..sort();
  if (missing.isNotEmpty) {
    stderr.writeln(
      'Missing required Firebase Web build variables: ${missing.join(', ')}',
    );
    stderr.writeln(
      'Set them in the environment or copy '
      'config/firebase.web.example.json to config/firebase.web.json.',
    );
    exitCode = 64;
    return;
  }

  final arguments = <String>['build', 'web', '--release'];
  for (final key in _firebaseKeys) {
    final value = values[key];
    if (value != null) arguments.add('--dart-define=$key=$value');
  }

  stdout.writeln('Building the Flutter web release bundle...');
  try {
    final process = await Process.start(
      'flutter',
      arguments,
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    exitCode = await process.exitCode;
  } on ProcessException catch (error) {
    stderr.writeln('Unable to start Flutter: ${error.message}');
    exitCode = 69;
  }
}

Future<Map<String, String>?> _readLocalConfig() async {
  final file = File('config/firebase.web.json');
  if (!await file.exists()) return const {};

  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }

    return decoded.map(
      (key, value) => MapEntry(
        key,
        value == null ? '' : (value is String ? value : '$value'),
      ),
    );
  } on FormatException catch (error) {
    stderr.writeln('Invalid config/firebase.web.json: ${error.message}');
    exitCode = 65;
    return null;
  }
}
