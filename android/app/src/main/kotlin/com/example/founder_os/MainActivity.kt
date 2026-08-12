package com.example.founder_os

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
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
    private val criticalRequestCode = 7001
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
                                    if (stream != null) file.failWrite(stream)
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
                            if (file.baseFile.exists()) file.delete()
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
                    "requestNotificationPermission" -> {
                        ensureNotificationPermission()
                        result.success(
                            Build.VERSION.SDK_INT < 33 ||
                                checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
                                PackageManager.PERMISSION_GRANTED,
                        )
                    }
                    "scheduleCriticalNotification" -> {
                        val title = call.argument<String>("title")
                        val body = call.argument<String>("body")
                        val delaySeconds = call.argument<Int>("delaySeconds")
                        if (title == null || body == null || delaySeconds == null) {
                            result.error(
                                "invalid_arguments",
                                "title, body and delaySeconds are required.",
                                null,
                            )
                        } else {
                            ensureNotificationPermission()
                            scheduleCriticalNotification(title, body, delaySeconds)
                            result.success(true)
                        }
                    }
                    "cancelCriticalNotification" -> {
                        cancelCriticalNotification()
                        result.success(true)
                    }
                    "diagnostics" -> result.success(
                        mapOf(
                            "available" to true,
                            "backend" to "kotlin_atomic_file",
                            "platform" to "android",
                            "backgroundCriticalNotifications" to true,
                        ),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun ensureNotificationPermission() {
        if (
            Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 7002)
        }
    }

    private fun criticalPendingIntent(
        title: String = "",
        body: String = "",
    ): PendingIntent {
        val intent = Intent(this, CriticalNotificationReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
        }
        return PendingIntent.getBroadcast(
            this,
            criticalRequestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun scheduleCriticalNotification(
        title: String,
        body: String,
        delaySeconds: Int,
    ) {
        val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerAt = SystemClock.elapsedRealtime() +
            maxOf(1, delaySeconds).toLong() * 1000L
        alarm.setAndAllowWhileIdle(
            AlarmManager.ELAPSED_REALTIME_WAKEUP,
            triggerAt,
            criticalPendingIntent(title, body),
        )
    }

    private fun cancelCriticalNotification() {
        val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarm.cancel(criticalPendingIntent())
    }

    private fun atomicSnapshotFile(): AtomicFile {
        val directory = File(filesDir, "founder_os")
        if (!directory.exists() && !directory.mkdirs()) {
            throw IllegalStateException("Could not create snapshot directory")
        }
        return AtomicFile(File(directory, "snapshot-v10.json"))
    }
}
