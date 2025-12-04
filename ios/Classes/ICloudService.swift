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
    /// - "isDownloading": Bool - идет ли загрузка сейчас
    /// - "downloadRequested": Bool - была ли запрошена загрузка
    /// - "isUbiquitous": Bool - является ли файл iCloud-файлом
    /// - "fileSize": Int64 - размер файла (если доступен)
    @objc public static func getFileDownloadStatus(path: String) -> [String: Any] {
        let fileURL = URL(fileURLWithPath: path)
        let fileManager = FileManager.default

        // Проверяем существование файла
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return [
                "status": "notFound",
                "isDownloading": false,
                "downloadRequested": false,
                "isUbiquitous": false,
                "fileSize": 0
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
                "isUbiquitous": false,
                "fileSize": fileSize
            ]
        }

        do {
            // Получаем все доступные ключи для iCloud файла
            let resourceValues = try fileURL.resourceValues(forKeys: [
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey,
                .ubiquitousItemDownloadRequestedKey,
                .fileSizeKey
            ])

            let isDownloading = resourceValues.ubiquitousItemIsDownloading ?? false
            let downloadRequested = resourceValues.ubiquitousItemDownloadRequested ?? false
            let fileSize = resourceValues.fileSize ?? 0

            var status = "unknown"
            if let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus {
                if downloadStatus == .current {
                    status = "current"
                } else if downloadStatus == .downloaded {
                    status = "downloaded"
                } else if downloadStatus == .notDownloaded {
                    status = "notDownloaded"
                }
            }

            return [
                "status": status,
                "isDownloading": isDownloading,
                "downloadRequested": downloadRequested,
                "isUbiquitous": true,
                "fileSize": fileSize
            ]
        } catch {
            return [
                "status": "error",
                "isDownloading": false,
                "downloadRequested": false,
                "isUbiquitous": true,
                "fileSize": 0,
                "error": error.localizedDescription
            ]
        }
    }
}

