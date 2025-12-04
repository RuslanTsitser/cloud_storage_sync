package com.tsitser.cloud_storage_sync

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CloudStorageSyncPlugin */
class CloudStorageSyncPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cloud_storage_sync")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "isCloudStorageAvailable" -> {
                // Android support will be added in future versions
                result.success(false)
            }
            "getCloudContainerPath" -> {
                result.success(null)
            }
            "getDatabasePath" -> {
                result.success(null)
            }
            "getDocumentsDirectoryPath" -> {
                result.success(null)
            }
            "getDatabaseSyncStatus" -> {
                result.success(mapOf(
                    "isSynced" to false,
                    "isAvailable" to false,
                    "error" to "Cloud storage not yet supported on Android"
                ))
            }
            "getFileSyncStatus" -> {
                result.success(mapOf(
                    "isSynced" to false,
                    "isAvailable" to false,
                    "error" to "Cloud storage not yet supported on Android"
                ))
            }
            "isFileFullyDownloaded" -> {
                result.success(false)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
