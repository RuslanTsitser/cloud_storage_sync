# cloud_storage_sync

Flutter plugin for iCloud Drive integration on iOS. Provides access to iCloud Documents directory for automatic file synchronization.

## Features

- ✅ iCloud Drive integration for iOS
- ✅ Automatic file synchronization (handled by iOS)
- ✅ Automatic fallback to local storage
- 🔜 Google Drive support for Android (coming soon)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  cloud_storage_sync:
    path: ./cloud_storage_sync  # For local development
    # Or from pub.dev (when published):
    # cloud_storage_sync: ^0.1.0
```

## iOS Setup

### 1. Register iCloud Container in Apple Developer Portal

**Required!** Without this, iCloud will not work.

1. Open [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. Sign in to your account
3. Go to **Identifiers** section
4. Click **+** to create a new identifier
5. Select **iCloud Containers**
6. Click **Continue**
7. Enter identifier: `iCloud.com.yourcompany.yourapp` (replace with your bundle identifier)
8. Click **Continue** and **Register**
9. Open your App ID in Identifiers section
10. In **iCloud Containers** section, link the container to your App ID

**Note:** App Store Connect is not needed, only Apple Developer Portal.

### 2. Configure in Xcode

1. Open your iOS project in Xcode
2. Select the `Runner` target
3. Go to **Signing & Capabilities** tab
4. Ensure **Code Signing Entitlements** points to `Runner/Runner.entitlements`
5. Click **+ Capability** button (top left)
6. Add **iCloud** capability
7. In **iCloud** section:
   - ✅ Enable **iCloud Documents** (check the radio button)
   - ❌ Do NOT enable **Key-value storage** (not needed)
   - ❌ Do NOT enable **CloudKit** (not needed)
8. In **Containers** section:
   - Click **+** button
   - Add your container: `iCloud.com.yourcompany.yourapp` (replace with your container identifier)
   - Or select it from the list if it already exists
9. Click **Try Again** in Signing section if there are any errors

**Note:** If you see "Provisioning profile doesn't include entitlement" error, make sure you've completed step 1 (registering container in Apple Developer Portal) and wait a few minutes for provisioning profile to update.

### 3. Enable iCloud Drive on Device

1. Open **Settings** > **[Your Name]** > **iCloud**
2. Enable **iCloud Drive**
3. Wait 10-30 seconds
4. Restart the app

### 4. Use Real Device

- iCloud on simulator works unreliably
- Use a real iOS device for testing

## Troubleshooting

### Error: "Provisioning profile doesn't include entitlement"

This usually means:

- Container is not registered in Apple Developer Portal (complete step 1)
- Container is not linked to your App ID
- Wait a few minutes after registering container for provisioning profile to update
- Click "Try Again" in Xcode Signing section

### Error: "iCloud not available" in logs

1. **Container not registered**: Register it in Apple Developer Portal (see step 1 above)
2. **iCloud Drive disabled**: Enable it in device settings
3. **Using simulator**: Use a real device instead
4. **Wrong capabilities**: Make sure only "iCloud Documents" is enabled, not "Key-value storage"

Check logs for detailed diagnostics with `[AppDirectory]` prefix.

## Usage

### Basic Usage

```dart
import 'package:cloud_storage_sync/cloud_storage_sync.dart';

// Check if cloud storage is available
final isAvailable = await CloudStorageSync.instance.isCloudStorageAvailable();

// Get documents directory path in iCloud
// Returns null if iCloud is not available
final docsPath = await CloudStorageSync.instance.getDocumentsDirectoryPath();

if (docsPath != null) {
  // Use iCloud directory for file storage
  // Files saved here will be automatically synced by iOS
  final file = File('$docsPath/myfile.pdf');
  await file.writeAsBytes(data);
} else {
  // Fallback to local storage
  final appDir = await getApplicationDocumentsDirectory();
  final file = File('${appDir.path}/myfile.pdf');
  await file.writeAsBytes(data);
}
```

### How It Works

When you save files to the iCloud Documents directory, iOS automatically synchronizes them in the background. No additional sync calls are needed - just save files to the directory path returned by `getDocumentsDirectoryPath()`.

The plugin provides:

- **Transparent synchronization**: Files are automatically synced by iOS
- **Automatic fallback**: If iCloud is unavailable, use local storage
- **Simple API**: Just check availability and get the directory path

## Example

See the `example/` directory for a complete example.

## Platform Support

| Platform | Status |
|----------|--------|
| iOS      | ✅ Supported |
| Android  | 🔜 Coming soon |

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
