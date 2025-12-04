import 'dart:io';

import '../cloud_storage_sync_platform_interface.dart';

/// Сервис для работы с облачным хранилищем
abstract class CloudStorageService {
  /// Проверяет, доступно ли облачное хранилище
  Future<bool> isCloudStorageAvailable();

  /// Получает путь к директории документов в облаке
  Future<String?> getDocumentsDirectoryPath();

  /// Проверяет, полностью ли скачан файл по указанному пути
  Future<bool> isFileFullyDownloaded(String filePath);
}

/// Реализация CloudStorageService
class CloudStorageServiceImpl implements CloudStorageService {
  CloudStorageServiceImpl({
    required CloudStorageSyncPlatform platform,
  }) : _platform = platform;

  final CloudStorageSyncPlatform _platform;

  @override
  Future<bool> isCloudStorageAvailable() async {
    if (!Platform.isIOS) {
      return false;
    }
    try {
      final result = await _platform.invokeMethod<bool>('isCloudStorageAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getDocumentsDirectoryPath() async {
    if (!Platform.isIOS) {
      return null;
    }
    try {
      final result = await _platform.invokeMethod<String>('getDocumentsDirectoryPath');
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isFileFullyDownloaded(String filePath) async {
    if (!Platform.isIOS) {
      return false;
    }
    if (filePath.isEmpty) {
      return false;
    }
    try {
      final result = await _platform.invokeMethod<bool>('isFileFullyDownloaded', <String, dynamic>{
        'path': filePath,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}

