package com.example.founder_os

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class CriticalNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "founder_os_critical"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    channelId,
                    "Critical game events",
                    NotificationManager.IMPORTANCE_HIGH,
                ),
            )
        }

        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingLaunch = PendingIntent.getActivity(
            context,
            7003,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(android.R.drawable.stat_notify_error)
            .setContentTitle(intent.getStringExtra("title") ?: "FOUNDER.OS")
            .setContentText(intent.getStringExtra("body") ?: "Simulation paused")
            .setAutoCancel(true)
            .setContentIntent(pendingLaunch)
            .build()
        manager.notify(7001, notification)
    }
}
