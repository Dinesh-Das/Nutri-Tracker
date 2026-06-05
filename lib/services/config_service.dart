import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigService {
  ConfigService({
    FlutterSecureStorage? secureStorage,
    FirebaseRemoteConfig? remoteConfig,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const _proxyUrlKey = 'nutribot_proxy_url';

  final FlutterSecureStorage _secureStorage;
  final FirebaseRemoteConfig _remoteConfig;

  Future<String> getNutriBotProxyUrl() async {
    final cached = await _secureStorage.read(key: _proxyUrlKey);
    if (cached != null && cached.trim().isNotEmpty) return cached.trim();

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
    final remoteValue = _remoteConfig.getString(_proxyUrlKey).trim();
    if (remoteValue.isNotEmpty) {
      await _secureStorage.write(key: _proxyUrlKey, value: remoteValue);
    }
    return remoteValue;
  }

  Future<void> setNutriBotProxyUrl(String value) {
    return _secureStorage.write(key: _proxyUrlKey, value: value.trim());
  }
}
