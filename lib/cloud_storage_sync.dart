export 'cloud_storage_sync_platform_interface.dart';
export 'src/cloud_storage_service.dart' show FileDownloadStatus, FileDownloadInfo;

import 'src/cloud_storage_service.dart';
import 'cloud_storage_sync_platform_interface.dart';

/// Главный класс плагина для синхронизации облачного хранилища
class CloudStorageSync {
  CloudStorageSync._();

  static final CloudStorageSync _instance = CloudStorageSync._();
  static CloudStorageSync get instance => _instance;

  /// Сервис для работы с облачным хранилищем
  CloudStorageService get service => CloudStorageServiceImpl(
        platform: CloudStorageSyncPlatform.instance,
      );

  /// Проверяет, доступно ли облачное хранилище
  Future<bool> isCloudStorageAvailable() {
    return service.isCloudStorageAvailable();
  }

  /// Получает путь к директории документов в облаке
  Future<String?> getDocumentsDirectoryPath() {
    return service.getDocumentsDirectoryPath();
  }

  /// Получает информацию о статусе загрузки файла из iCloud
  Future<FileDownloadInfo?> getFileDownloadStatus(String filePath) {
    return service.getFileDownloadStatus(filePath);
  }
}
