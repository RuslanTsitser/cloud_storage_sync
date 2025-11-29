import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cloud_storage_sync_platform_interface.dart';

/// An implementation of [CloudStorageSyncPlatform] that uses method channels.
class MethodChannelCloudStorageSync extends CloudStorageSyncPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cloud_storage_sync');

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      final result = await methodChannel.invokeMethod<T>(method, arguments);
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to invoke method $method: ${e.message}');
    }
  }
}
