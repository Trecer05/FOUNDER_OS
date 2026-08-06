package com.example.founder_os

import android.os.SystemClock
import android.util.AtomicFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "founder_os/native_performance"
    private val snapshotExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadSnapshot" -> snapshotExecutor.execute {
                        try {
                            val file = atomicSnapshotFile()
                            val value = if (file.baseFile.exists()) {
                                String(file.readFully(), StandardCharsets.UTF_8)
                            } else {
                                null
                            }
                            runOnUiThread { result.success(value) }
                        } catch (error: Throwable) {
                            runOnUiThread {
                                result.error(
                                    "snapshot_load_failed",
                                    error.localizedMessage,
                                    null,
                                )
                            }
                        }
                    }
                    "saveSnapshot" -> {
                        val snapshot = call.argument<String>("snapshot")
                        if (snapshot == null) {
                            result.error(
                                "invalid_arguments",
                                "Snapshot string is required.",
                                null,
                            )
                        } else {
                            snapshotExecutor.execute {
                                val file = atomicSnapshotFile()
                                var stream: FileOutputStream? = null
                                try {
                                    stream = file.startWrite()
                                    stream.write(snapshot.toByteArray(StandardCharsets.UTF_8))
                                    file.finishWrite(stream)
                                    runOnUiThread { result.success(true) }
                                } catch (error: Throwable) {
                                    if (stream != null) {
                                        file.failWrite(stream)
                                    }
                                    runOnUiThread {
                                        result.error(
                                            "snapshot_save_failed",
                                            error.localizedMessage,
                                            null,
                                        )
                                    }
                                }
                            }
                        }
                    }
                    "clearSnapshot" -> snapshotExecutor.execute {
                        try {
                            val file = atomicSnapshotFile()
                            if (file.baseFile.exists()) {
                                file.delete()
                            }
                            runOnUiThread { result.success(true) }
                        } catch (error: Throwable) {
                            runOnUiThread {
                                result.error(
                                    "snapshot_clear_failed",
                                    error.localizedMessage,
                                    null,
                                )
                            }
                        }
                    }
                    "monotonicMicros" -> result.success(
                        SystemClock.elapsedRealtimeNanos() / 1_000L,
                    )
                    "diagnostics" -> result.success(
                        mapOf(
                            "available" to true,
                            "backend" to "kotlin_atomic_file",
                            "platform" to "android",
                        ),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun atomicSnapshotFile(): AtomicFile {
        val directory = File(filesDir, "founder_os")
        if (!directory.exists() && !directory.mkdirs()) {
            throw IllegalStateException("Could not create snapshot directory")
        }
        return AtomicFile(File(directory, "snapshot-v10.json"))
    }
}
