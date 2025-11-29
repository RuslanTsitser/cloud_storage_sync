import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_storage_sync/cloud_storage_sync.dart';
import 'package:cloud_storage_sync/cloud_storage_sync_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCloudStorageSyncPlatform
    with MockPlatformInterfaceMixin
    implements CloudStorageSyncPlatform {
  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    if (method == 'isCloudStorageAvailable') {
      return Future.value(false as T);
    }
    return Future.value(null);
  }
}

void main() {
  final CloudStorageSyncPlatform initialPlatform = CloudStorageSyncPlatform.instance;

  test('$MethodChannelCloudStorageSync is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCloudStorageSync>());
  });

  test('isCloudStorageAvailable', () async {
    final cloudStorageSyncPlugin = CloudStorageSync.instance;
    final fakePlatform = MockCloudStorageSyncPlatform();
    CloudStorageSyncPlatform.instance = fakePlatform;

    expect(await cloudStorageSyncPlugin.isCloudStorageAvailable(), false);
  });
}
