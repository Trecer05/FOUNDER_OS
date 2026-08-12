import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let performanceChannelName = "founder_os/native_performance"
  private let criticalNotificationId = "founder_os_critical"
  private let snapshotQueue = DispatchQueue(
    label: "founder_os.snapshot",
    qos: .utility
  )
  private var performanceChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: performanceChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handlePerformanceCall(call, result: result)
    }
    performanceChannel = channel
  }

  private func handlePerformanceCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadSnapshot":
      snapshotQueue.async { [weak self] in
        guard let self else { return }
        do {
          let url = try self.snapshotURL()
          let value = FileManager.default.fileExists(atPath: url.path)
            ? try String(contentsOf: url, encoding: .utf8)
            : nil
          DispatchQueue.main.async { result(value) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "snapshot_load_failed",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
      }
    case "saveSnapshot":
      guard
        let arguments = call.arguments as? [String: Any],
        let snapshot = arguments["snapshot"] as? String
      else {
        result(FlutterError(
          code: "invalid_arguments",
          message: "Snapshot string is required.",
          details: nil
        ))
        return
      }
      snapshotQueue.async { [weak self] in
        guard let self else { return }
        do {
          let url = try self.snapshotURL()
          let data = Data(snapshot.utf8)
          try data.write(to: url, options: [.atomic])
          DispatchQueue.main.async { result(true) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "snapshot_save_failed",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
      }
    case "clearSnapshot":
      snapshotQueue.async { [weak self] in
        guard let self else { return }
        do {
          let url = try self.snapshotURL()
          if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
          }
          DispatchQueue.main.async { result(true) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "snapshot_clear_failed",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
      }
    case "monotonicMicros":
      result(Int64(ProcessInfo.processInfo.systemUptime * 1_000_000))
    case "requestNotificationPermission":
      UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
      ) { granted, _ in
        DispatchQueue.main.async { result(granted) }
      }
    case "scheduleCriticalNotification":
      guard
        let arguments = call.arguments as? [String: Any],
        let title = arguments["title"] as? String,
        let body = arguments["body"] as? String,
        let delaySeconds = arguments["delaySeconds"] as? Int
      else {
        result(FlutterError(
          code: "invalid_arguments",
          message: "title, body and delaySeconds are required.",
          details: nil
        ))
        return
      }
      scheduleCriticalNotification(
        title: title,
        body: body,
        delaySeconds: delaySeconds,
        result: result
      )
    case "cancelCriticalNotification":
      UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: [criticalNotificationId]
      )
      result(true)
    case "diagnostics":
      result([
        "available": true,
        "backend": "swift_atomic_file",
        "platform": "ios",
        "backgroundCriticalNotifications": true,
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func scheduleCriticalNotification(
    title: String,
    body: String,
    delaySeconds: Int,
    result: @escaping FlutterResult
  ) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
      guard let self else { return }
      if let error {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "notification_permission_failed",
            message: error.localizedDescription,
            details: nil
          ))
        }
        return
      }
      guard granted else {
        DispatchQueue.main.async { result(false) }
        return
      }

      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      content.sound = .default
      let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: TimeInterval(max(1, delaySeconds)),
        repeats: false
      )
      let request = UNNotificationRequest(
        identifier: self.criticalNotificationId,
        content: content,
        trigger: trigger
      )
      center.removePendingNotificationRequests(
        withIdentifiers: [self.criticalNotificationId]
      )
      center.add(request) { error in
        DispatchQueue.main.async {
          if let error {
            result(FlutterError(
              code: "notification_schedule_failed",
              message: error.localizedDescription,
              details: nil
            ))
          } else {
            result(true)
          }
        }
      }
    }
  }

  private func snapshotURL() throws -> URL {
    let applicationSupport = try FileManager.default.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let directory = applicationSupport.appendingPathComponent(
      "FOUNDER.OS",
      isDirectory: true
    )
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    return directory.appendingPathComponent("snapshot-v10.json")
  }
}
