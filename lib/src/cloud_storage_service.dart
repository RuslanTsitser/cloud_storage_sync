import 'dart:io';

import '../cloud_storage_sync_platform_interface.dart';

/// Статус загрузки файла из iCloud
enum FileDownloadStatus {
  /// Файл полностью загружен и актуален
  current,
  /// Файл загружен локально (может быть не актуален)
  downloaded,
  /// Файл не загружен (только в облаке)
  notDownloaded,
  /// Локальный файл (не iCloud)
  local,
  /// Файл не найден
  notFound,
  /// Неизвестный статус
  unknown,
  /// Ошибка при получении статуса
  error,
}

/// Информация о статусе загрузки файла из iCloud
class FileDownloadInfo {
  const FileDownloadInfo({
    required this.status,
    required this.isDownloading,
    required this.downloadRequested,
    required this.isUbiquitous,
    required this.fileSize,
    this.error,
  });

  /// Статус загрузки файла
  final FileDownloadStatus status;

  /// Идет ли загрузка сейчас
  final bool isDownloading;

  /// Была ли запрошена загрузка
  final bool downloadRequested;

  /// Является ли файл iCloud-файлом
  final bool isUbiquitous;

  /// Размер файла в байтах
  final int fileSize;

  /// Сообщение об ошибке (если есть)
  final String? error;

  /// Файл доступен для использования (загружен локально)
  bool get isAvailable =>
      status == FileDownloadStatus.current ||
      status == FileDownloadStatus.downloaded ||
      status == FileDownloadStatus.local;

  @override
  String toString() {
    return 'FileDownloadInfo(status: $status, isDownloading: $isDownloading, '
        'downloadRequested: $downloadRequested, isUbiquitous: $isUbiquitous, '
        'fileSize: $fileSize, error: $error)';
  }
}

/// Сервис для работы с облачным хранилищем
abstract class CloudStorageService {
  /// Проверяет, доступно ли облачное хранилище
  Future<bool> isCloudStorageAvailable();

  /// Получает путь к директории документов в облаке
  Future<String?> getDocumentsDirectoryPath();

  /// Получает информацию о статусе загрузки файла по указанному пути
  Future<FileDownloadInfo?> getFileDownloadStatus(String filePath);
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
  Future<FileDownloadInfo?> getFileDownloadStatus(String filePath) async {
    if (!Platform.isIOS) {
      return null;
    }
    if (filePath.isEmpty) {
      return null;
    }
    try {
      final result = await _platform.invokeMethod<Map<Object?, Object?>>('getFileDownloadStatus', <String, dynamic>{
        'path': filePath,
      });
      if (result == null) {
        return null;
      }

      final statusString = result['status'] as String? ?? 'unknown';
      final status = _parseStatus(statusString);

      return FileDownloadInfo(
        status: status,
        isDownloading: result['isDownloading'] as bool? ?? false,
        downloadRequested: result['downloadRequested'] as bool? ?? false,
        isUbiquitous: result['isUbiquitous'] as bool? ?? false,
        fileSize: (result['fileSize'] as num?)?.toInt() ?? 0,
        error: result['error'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  FileDownloadStatus _parseStatus(String status) {
    switch (status) {
      case 'current':
        return FileDownloadStatus.current;
      case 'downloaded':
        return FileDownloadStatus.downloaded;
      case 'notDownloaded':
        return FileDownloadStatus.notDownloaded;
      case 'local':
        return FileDownloadStatus.local;
      case 'notFound':
        return FileDownloadStatus.notFound;
      case 'error':
        return FileDownloadStatus.error;
      default:
        return FileDownloadStatus.unknown;
    }
  }
}

