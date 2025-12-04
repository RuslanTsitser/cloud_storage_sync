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

    /// Проверяет, полностью ли загружен файл из iCloud
    /// Возвращает true если файл полностью скачан и доступен локально
    @objc public static func isFileFullyDownloaded(path: String) -> Bool {
        let fileURL = URL(fileURLWithPath: path)
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return false
        }

        // Для локальных файлов (не iCloud) считаем, что они полностью доступны
        guard fileManager.isUbiquitousItem(at: fileURL) else {
            return true
        }

        do {
            // Используем только ubiquitousItemDownloadingStatusKey - он доступен в iOS
            let resourceValues = try fileURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])

            if let status = resourceValues.ubiquitousItemDownloadingStatus {
                // .current означает, что файл полностью загружен и актуален
                // .notDownloaded - файл только в облаке (placeholder)
                // .downloaded - файл загружен, но может быть не актуален
                return status == URLUbiquitousItemDownloadingStatus.current
            }

            // Если статус недоступен, пробуем читать файл для проверки
            return fileManager.isReadableFile(atPath: fileURL.path)
        } catch {
            return false
        }
    }
}

