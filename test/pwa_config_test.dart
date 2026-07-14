import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PWA configuration', () {
    test('manifest has an installable identity and correctly sized icons', () {
      final manifest = jsonDecode(File('web/manifest.json').readAsStringSync())
          as Map<String, dynamic>;

      expect(manifest['name'], 'NutriTrack India');
      expect(manifest['short_name'], 'NutriTrack');
      expect(manifest['start_url'], '/');
      expect(manifest['scope'], '/');
      expect(manifest['display'], 'standalone');
      expect(manifest['theme_color'], '#006D77');

      final icons = (manifest['icons'] as List).cast<Map<String, dynamic>>();
      expect(icons.map((icon) => icon['sizes']),
          containsAll(['192x192', '512x512']));
      expect(icons.map((icon) => icon['purpose']),
          containsAll(['any', 'maskable']));

      for (final icon in icons) {
        final size = int.parse((icon['sizes'] as String).split('x').first);
        final dimensions = _pngDimensions(File('web/${icon['src']}'));
        expect(dimensions, (size, size), reason: icon['src'] as String);
      }

      expect(
        _pngDimensions(File('web/icons/apple-touch-icon.png')),
        (180, 180),
      );
      expect(_pngDimensions(File('web/favicon-32.png')), (32, 32));
    });

    test('bootstrap registers the custom worker and uses the Flutter loader',
        () {
      final index = File('web/index.html').readAsStringSync();
      final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();
      final worker = File('web/sw.js').readAsStringSync();

      expect(index, contains('rel="manifest"'));
      expect(index, contains('flutter_bootstrap.js'));
      expect(index, isNot(contains('flutter_service_worker.js')));
      expect(bootstrap, contains("register(workerUrl)"));
      expect(bootstrap, contains('_flutter.loader.load({'));
      expect(bootstrap, contains('canvasKitBaseUrl'));
      expect(worker, contains("self.addEventListener('fetch'"));
      expect(worker, contains("request.mode === 'navigate'"));
      expect(worker, contains('./canvaskit/canvaskit.wasm'));
    });

    test('Firebase Hosting serves SPA routes and refreshes the worker', () {
      final config = jsonDecode(File('firebase.json').readAsStringSync())
          as Map<String, dynamic>;
      final hosting = config['hosting'] as Map<String, dynamic>;
      final rewrites =
          (hosting['rewrites'] as List).cast<Map<String, dynamic>>();
      final headers = (hosting['headers'] as List).cast<Map<String, dynamic>>();

      expect(hosting['public'], 'build/web');
      expect(
        rewrites,
        contains(predicate<Map<String, dynamic>>(
          (entry) =>
              entry['source'] == '**' && entry['destination'] == '/index.html',
        )),
      );
      expect(
        headers,
        contains(predicate<Map<String, dynamic>>(
          (entry) => entry['source'] == '/sw.js',
        )),
      );
    });

    test('Vercel serves the web build with SPA and PWA-safe settings', () {
      final config = jsonDecode(File('vercel.json').readAsStringSync())
          as Map<String, dynamic>;
      final rewrites =
          (config['rewrites'] as List).cast<Map<String, dynamic>>();
      final headers = (config['headers'] as List).cast<Map<String, dynamic>>();

      expect(config['framework'], isNull);
      expect(config['buildCommand'], 'dart run tool/build_web.dart');
      expect(config['outputDirectory'], 'build/web');
      expect(
        rewrites,
        contains(predicate<Map<String, dynamic>>(
          (entry) =>
              entry['source'] == '/(.*)' &&
              entry['destination'] == '/index.html',
        )),
      );
      expect(
        headers,
        contains(predicate<Map<String, dynamic>>(
          (entry) => entry['source'] == '/sw.js',
        )),
      );
      expect(
        headers,
        contains(predicate<Map<String, dynamic>>(
          (entry) => entry['source'] == '/manifest.json',
        )),
      );
    });
  });
}

(int, int) _pngDimensions(File file) {
  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(24), reason: file.path);
  expect(bytes.sublist(1, 4), [80, 78, 71], reason: file.path);
  return (_uint32(bytes, 16), _uint32(bytes, 20));
}

int _uint32(List<int> bytes, int offset) {
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}
