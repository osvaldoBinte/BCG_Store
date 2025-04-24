package com.binteconsulting.bcgstore

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaScannerConnection

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.bgcstore.mediaScanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                scanFile(path, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanFile(path: String?, result: MethodChannel.Result) {
        try {
            if (path == null) {
                result.error("NULL_PATH", "Path cannot be null", null)
                return
            }
            
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(path),
                null
            ) { _, _ ->
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("SCAN_ERROR", e.message, null)
        }
    }
}   