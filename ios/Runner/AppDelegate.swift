import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let performanceChannelName = "founder_os/native_performance"
  private let snapshotQueue = DispatchQueue(
    label: "founder_os.snapshot",
    qos: .utility
  )
  private var performanceChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
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
    case "diagnostics":
      result([
        "available": true,
        "backend": "swift_atomic_file",
        "platform": "ios",
      ])
    default:
      result(FlutterMethodNotImplemented)
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
