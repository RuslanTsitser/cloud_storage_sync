import 'package:cloud_storage_sync/cloud_storage_sync_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelCloudStorageSync();
  const MethodChannel channel = MethodChannel('cloud_storage_sync');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'isCloudStorageAvailable') {
        return false;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('isCloudStorageAvailable', () async {
    final result = await platform.invokeMethod<bool>('isCloudStorageAvailable');
    expect(result, false);
  });
}
