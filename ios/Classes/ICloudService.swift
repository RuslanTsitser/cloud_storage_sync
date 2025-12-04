import Foundation
import Flutter

@objc public class ICloudService: NSObject {
    private static let iCloudContainerIdentifier = "iCloud.com.tsitser.pregnancyBook"
    
    /// Получает URL iCloud контейнера (используется внутренне)
    private static func getICloudContainerURL() -> URL? {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: iCloudContainerIdentifier) else {
            return nil
        }
        return containerURL
    }
    
    /// Получает URL для директории документов в iCloud
    @objc public static func getDocumentsDirectoryURL() -> URL? {
        guard let containerURL = getICloudContainerURL() else {
            return nil
        }
        return containerURL.appendingPathComponent("Documents")
    }
    
    /// Проверяет, доступен ли iCloud
    @objc public static func isICloudAvailable() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    /// Получает информацию о статусе загрузки файла из iCloud
    /// Возвращает словарь с информацией:
    /// - "status": "current" | "downloaded" | "notDownloaded" | "local" | "notFound" | "error"
    /// - "isDownloading": Bool - идет ли загрузка ИЗ облака сейчас
    /// - "downloadRequested": Bool - была ли запрошена загрузка ИЗ облака
    /// - "isUploading": Bool - идет ли загрузка В облако сейчас
    /// - "isUploaded": Bool - загружен ли файл В облако
    /// - "isUbiquitous": Bool - является ли файл iCloud-файлом
    /// - "fileSize": Int64 - размер файла (если доступен)
    /// - "isReadable": Bool - можно ли открыть файл для чтения
    @objc public static func getFileDownloadStatus(path: String) -> [String: Any] {
        let fileURL = URL(fileURLWithPath: path)
        let fileManager = FileManager.default

        // Проверяем существование файла
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return [
                "status": "notFound",
                "isDownloading": false,
                "downloadRequested": false,
                "isUploading": false,
                "isUploaded": false,
                "isUbiquitous": false,
                "fileSize": 0,
                "isReadable": false
            ]
        }

        // Для локальных файлов (не iCloud) возвращаем "local"
        let isUbiquitous = fileManager.isUbiquitousItem(at: fileURL)
        guard isUbiquitous else {
            // Получаем размер локального файла
            var fileSize: Int64 = 0
            if let attrs = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let size = attrs[.size] as? Int64 {
                fileSize = size
            }
            return [
                "status": "local",
                "isDownloading": false,
                "downloadRequested": false,
                "isUploading": false,
                "isUploaded": false,
                "isUbiquitous": false,
                "fileSize": fileSize,
                "isReadable": true
            ]
        }

        do {
            // Получаем все доступные ключи для iCloud файла
            let resourceValues = try fileURL.resourceValues(forKeys: [
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey,
                .ubiquitousItemDownloadRequestedKey,
                .ubiquitousItemIsUploadingKey,
                .ubiquitousItemIsUploadedKey,
                .fileSizeKey
            ])

            let isDownloading = resourceValues.ubiquitousItemIsDownloading ?? false
            let downloadRequested = resourceValues.ubiquitousItemDownloadRequested ?? false
            let isUploading = resourceValues.ubiquitousItemIsUploading ?? false
            let isUploaded = resourceValues.ubiquitousItemIsUploaded ?? false
            let fileSize = resourceValues.fileSize ?? 0
            
            // Проверяем, можно ли реально открыть файл для чтения
            var isReadable = false
            if let fileHandle = try? FileHandle(forReadingFrom: fileURL) {
                // Пробуем прочитать первые байты (используем старый API для совместимости)
                let data = fileHandle.readData(ofLength: 1)
                isReadable = !data.isEmpty
                fileHandle.closeFile()
            }

            var status = "unknown"
            if let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus {
                if downloadStatus == .current {
                    status = "current"
                } else if downloadStatus == .downloaded {
                    status = "downloaded"
                } else if downloadStatus == .notDownloaded {
                    // Если статус notDownloaded, но файл читаемый - 
                    // это файл, созданный локально и еще не синхронизированный
                    if isReadable {
                        status = "localNotUploaded"
                    } else {
                        status = "notDownloaded"
                    }
                }
            }

            return [
                "status": status,
                "isDownloading": isDownloading,
                "downloadRequested": downloadRequested,
                "isUploading": isUploading,
                "isUploaded": isUploaded,
                "isUbiquitous": true,
                "fileSize": fileSize,
                "isReadable": isReadable
            ]
        } catch {
            return [
                "status": "error",
                "isDownloading": false,
                "downloadRequested": false,
                "isUploading": false,
                "isUploaded": false,
                "isUbiquitous": true,
                "fileSize": 0,
                "isReadable": false,
                "error": error.localizedDescription
            ]
        }
    }
}

