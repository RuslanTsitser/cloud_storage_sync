import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cloud_storage_sync_method_channel.dart';

abstract class CloudStorageSyncPlatform extends PlatformInterface {
  /// Constructs a CloudStorageSyncPlatform.
  CloudStorageSyncPlatform() : super(token: _token);

  static final Object _token = Object();

  static CloudStorageSyncPlatform _instance = MethodChannelCloudStorageSync();

  /// The default instance of [CloudStorageSyncPlatform] to use.
  ///
  /// Defaults to [MethodChannelCloudStorageSync].
  static CloudStorageSyncPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CloudStorageSyncPlatform] when
  /// they register themselves.
  static set instance(CloudStorageSyncPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Вызывает метод на нативной платформе
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }
}
