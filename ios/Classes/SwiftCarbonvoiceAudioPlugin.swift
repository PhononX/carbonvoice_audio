import Flutter
import UIKit
import AVFAudio

public class SwiftCarbonvoiceAudioPlugin: NSObject {

    private var audioController: AudioControllerProtocol = AudioController()

    private var playerController: PlayerControllerProtocol = PlayerController()

    private var recorderController: RecorderControllerProtocol = RecorderController()

    private var eventSink: FlutterEventSink?

    override init() {
        super.init()
        audioController.delegate = self
        playerController.delegate = self
        recorderController.delegate = self
        configureStreamHandler()
    }
}

// MARK: - FlutterPlugin

extension SwiftCarbonvoiceAudioPlugin: FlutterPlugin {

    private static let channelName: String = "carbonvoice_audio"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftCarbonvoiceAudioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

            // MARK: - AudioController

        case "getCurrentInputPortName":
            result(audioController.getCurrentInput()?.portName ?? nil)

        case "getCurrentInputPortType":
            result(audioController.getCurrentInput()?.portType.rawValue ?? nil)

        case "getCurrentOutputPortName":
            result(audioController.getCurrentOutput()?.portName ?? nil)

        case "getCurrentOutputPortType":
            result(audioController.getCurrentOutput()?.portType.rawValue ?? nil)

        case "getCurrentSessionCategoryName":
            result(audioController.getCurrentSessionCategoryName() ?? nil)

        case "setSessionActive":
            guard let arguments = call.arguments as? [String: Any], let active = arguments["active"] as? Bool else {
                result(FlutterError(code: "", message: "missing arguments for setSessionActive", details: nil))
                return
            }
            audioController.setSessionActive(active) { swiftResult in
                switch swiftResult {
                case .success:
                    result("success")
                case .failure(let error):
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                }
            }

        case "setSessionCategory":
            guard let arguments = call.arguments as? [String: Any], let category = arguments["category"] as? String else {
                result(FlutterError(code: "", message: "missing arguments for setSessionCategory", details: nil))
                return
            }
            audioController.setSessionCategory(category) { swiftResult in
                switch swiftResult {
                case .success:
                    result("success")
                case .failure(let error):
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                }
            }

            // MARK: - PlayerController

        case "getPlayerCurrentTimeInSeconds":
            result(playerController.getCurrentTimeInSeconds() ?? nil)

        case "getPlayerIsPlaying":
            result(playerController.isPlaying)

        case "setPlayerPlaybackSpeed":
            guard let arguments = call.arguments as? [String: Any], let playbackSpeed = arguments["playbackSpeed"] as? Float else {
                result(FlutterError(code: "", message: "missing arguments for setPlayerPlaybackSpeed", details: nil))
                return
            }
            playerController.setPlaybackSpeed(playbackSpeed)
            result("success")

        case "pausePlayer":
            playerController.pause()
            result("success")

        case "resumePlayer":
            playerController.resume()
            result("success")

        case "seekPlayer":
            guard let arguments = call.arguments as? [String: Any], let percentage = arguments["percentage"] as? Float else {
                result(FlutterError(code: "", message: "missing arguments for seekPlayer", details: nil))
                return
            }
            playerController.seek(to: percentage)
            result("success")

        case "rewindPlayer":
            guard let arguments = call.arguments as? [String: Any], let seconds = arguments["seconds"] as? Double else {
                result(FlutterError(code: "", message: "missing arguments for rewindPlayer", details: nil))
                return
            }
            playerController.rewind(seconds: seconds)
            result("success")

        case "playPlayer":
            guard
                let arguments = call.arguments as? [String: Any],
                let urlString = arguments["url"] as? String,
                let rate = arguments["rate"] as? Float,
                let position = arguments["position"] as? Float else {
                result(FlutterError(code: "", message: "missing arguments for playPlayer", details: nil))
                return
            }

            guard let url = URL(string: urlString) else {
                result(FlutterError(code: "", message: "invalid URL", details: nil))
                return
            }

            playerController.play(url: url, rate: rate, position: position) { swiftResult in
                switch swiftResult {
                case .success:
                    result("success")
                case .failure(let error):
                    result(FlutterError(code: "", message: error.localizedDescription, details: nil))
                }
            }

            // MARK: - RecorderController

        case "requestRecordPermission":
            recorderController.requestRecordPermission { granted in
                if granted {
                    result("success")
                } else {
                    result(FlutterError(code: "", message: "User denied record permission request", details: nil))
                }
            }

        case "getRecorderIsRecording":
            result(recorderController.isRecording)

        case "getRecorderIsSessionActive":
            result(recorderController.isSessionActive)

        case "startRecordingSession":
            do {
                try recorderController.startRecordingSession()
                result("success")
            } catch {
                result(FlutterError(code: "", message: error.localizedDescription, details: nil))
            }

        case "pauseRecording":
            recorderController.pauseRecording()
            result("success")

        case "resumeRecording":
            recorderController.resumeRecording()
            result("success")

        case "deleteRecordingSession":
            recorderController.deleteRecordingSession()
            result("success")

        case "endRecordingSession":
            recorderController.endRecordingSession { audioRecordingResult in
                guard let audioRecordingResult = audioRecordingResult else {
                    result(FlutterError(code: "", message: "Failed to end recording session", details: nil))
                    return
                }

                let resultToSend: [String: Any]

                if let transcription = audioRecordingResult.transcription, !transcription.isEmpty {
                    resultToSend = ["success": ["url": audioRecordingResult.url.absoluteURL,
                                                "transcription": transcription,
                                                "recordedTimeInMilliseconds": audioRecordingResult.recordedTimeInMilliseconds]]
                } else {
                    resultToSend = ["success": ["url": audioRecordingResult.url.absoluteURL,
                                                "recordedTimeInMilliseconds": audioRecordingResult.recordedTimeInMilliseconds]]
                }

                result(resultToSend)
            }

        default:
            result(FlutterError(code: "", message: "method call not supported: \(call.method)", details: nil))
        }
    }
}

// MARK: FlutterStreamHandler

extension SwiftCarbonvoiceAudioPlugin: FlutterStreamHandler {
    public func configureStreamHandler() {
        guard let controller = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }

        let notificationChannel = FlutterEventChannel(name: SwiftCarbonvoiceAudioPlugin.channelName,
                                                      binaryMessenger: controller.binaryMessenger)

        notificationChannel.setStreamHandler(self)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

// MARK: - AudioControllerDelegate

extension SwiftCarbonvoiceAudioPlugin: AudioControllerDelegate {
    func routeDidChange(inputPortName: String?, inputPortType: String?, outputPortName: String?, outputPortType: String?) {
        eventSink?(["routeDidChange": ["inputPortName": inputPortName,
                                       "inputPortType": inputPortType,
                                       "outputPortName": outputPortName,
                                       "outputPortType": outputPortType]])
    }

    func interruptionStarted() {
        eventSink?("interruptionStarted")
    }

    func interruptionEnded() {
        eventSink?("interruptionEnded")
    }
}

// MARK: - PlayerControllerDelegate

extension SwiftCarbonvoiceAudioPlugin: PlayerControllerDelegate {
    func timelineDidChange(timePlayed: String, timeRemaining: String, percentage: Float) {
        eventSink?(["timelineDidChange": ["timePlayed": timePlayed,
                                          "timeRemaining": timeRemaining,
                                          "percentage": percentage]])
    }

    func millisecondsHeardDidChange(milliseconds: Int, percentage: Float) {
        eventSink?(["millisecondsHeardDidChange": ["milliseconds": milliseconds,
                                                   "percentage": percentage]])
    }

    func playerDidFinishPlaying() {
        eventSink?("playerDidFinishPlaying")
    }
}

// MARK: - RecorderControllerDelegate

extension SwiftCarbonvoiceAudioPlugin: RecorderControllerDelegate {
    func recordedTimeDidChange(secondsRecorded: Int) {
        eventSink?(["recordedTimeDidChange": ["secondsRecorded": secondsRecorded]])
    }
}
