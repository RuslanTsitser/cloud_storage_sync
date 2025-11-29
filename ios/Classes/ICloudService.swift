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
}

