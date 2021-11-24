import Flutter
import CarbonVoiceAudio

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
                result(["error": "missing arguments for setSessionActive"])
                return
            }
            audioController.setSessionActive(active) { swiftResult in
                switch swiftResult {
                case .success:
                    result(["success": "true"])
                case .failure(let error):
                    result(["error": error.localizedDescription])
                }
            }

        case "setSessionCategory":
            guard let arguments = call.arguments as? [String: Any], let category = arguments["category"] as? String else {
                result(["error": "missing arguments for setSessionCategory"])
                return
            }
            audioController.setSessionCategory(category) { swiftResult in
                switch swiftResult {
                case .success:
                    result(["success": "true"])
                case .failure(let error):
                    result(["error": error.localizedDescription])
                }
            }

        case "showRoutePickerView":
            audioController.showRoutePickerView()
            result(["success": "true"])

            // MARK: - PlayerController

        case "getPlayerCurrentTimeInSeconds":
            result(playerController.getCurrentTimeInSeconds() ?? nil)

        case "getPlayerIsPlaying":
            result(playerController.isPlaying)

        case "setPlayerPlaybackSpeed":
            guard let arguments = call.arguments as? [String: Any], let playbackSpeed = arguments["playbackSpeed"] as? Double else {
                result(["error": "missing arguments for setPlayerPlaybackSpeed"])
                return
            }
            playerController.setPlaybackSpeed(playbackSpeed)
            result(["success": "true"])

        case "pausePlayer":
            playerController.pause()
            result(["success": "true"])

        case "resumePlayer":
            playerController.resume()
            result(["success": "true"])

        case "seekPlayer":
            guard let arguments = call.arguments as? [String: Any], let percentage = arguments["percentage"] as? Double else {
                result(["error": "missing arguments for seekPlayer"])
                return
            }
            playerController.seek(to: percentage)
            result(["success": "true"])

        case "rewindPlayer":
            guard let arguments = call.arguments as? [String: Any], let seconds = arguments["seconds"] as? Double else {
                result(["error": "missing arguments for rewindPlayer"])
                return
            }
            playerController.rewind(seconds: seconds)
            result(["success": "true"])

        case "playPlayer":
            guard
                let arguments = call.arguments as? [String: Any],
                let urlString = arguments["url"] as? String,
                let rate = arguments["rate"] as? Double,
                let position = arguments["position"] as? Double else {
                    result(["error": "missing arguments for playPlayer"])
                return
            }

            guard let url = URL(string: urlString) else {
                result(["error": "invalid URL"])
                return
            }

            playerController.play(url: url, rate: rate, position: position) { swiftResult in
                switch swiftResult {
                case .success:
                    result(["success": "true"])
                case .failure(let error):
                    result(["error": error.localizedDescription])
                }
            }

            // MARK: - RecorderController

        case "requestRecordPermission":
            recorderController.requestRecordPermission { granted in
                if granted {
                    result(["success": "true"])
                } else {
                    result(["error": "User denied record permission request"])
                }
            }

        case "getRecordPermissionState":
            result(recorderController.getRecordPermissionState())

        case "getRecorderIsRecording":
            result(recorderController.isRecording)

        case "getRecorderIsSessionActive":
            result(recorderController.isSessionActive)

        case "startRecordingSession":
            do {
                try recorderController.startRecordingSession()
                result(["success": "true"])
            } catch {
                result(["error": error.localizedDescription])
            }

        case "pauseRecording":
            recorderController.pauseRecording()
            result(["success": "true"])

        case "resumeRecording":
            recorderController.resumeRecording()
            result(["success": "true"])

        case "deleteRecordingSession":
            recorderController.deleteRecordingSession()
            result(["success": "true"])

        case "endRecordingSession":
            recorderController.endRecordingSession { audioRecordingResult in
                guard let audioRecordingResult = audioRecordingResult else {
                    result(["error": "Failed to end recording session"])
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
            result(["error": "method call not supported: \(call.method)"])
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
    public func routeDidChange(inputPortName: String?, inputPortType: String?, outputPortName: String?, outputPortType: String?) {
        eventSink?(["routeDidChange": ["inputPortName": inputPortName,
                                       "inputPortType": inputPortType,
                                       "outputPortName": outputPortName,
                                       "outputPortType": outputPortType]])
    }

    public func interruptionStarted() {
        eventSink?("interruptionStarted")
    }

    public func interruptionEnded() {
        eventSink?("interruptionEnded")
    }
}

// MARK: - PlayerControllerDelegate

extension SwiftCarbonvoiceAudioPlugin: PlayerControllerDelegate {
    public func timelineDidChange(timePlayed: String, timeRemaining: String, percentage: Double) {
        eventSink?(["timelineDidChange": ["timePlayed": timePlayed,
                                          "timeRemaining": timeRemaining,
                                          "percentage": percentage]])
    }

    public func millisecondsHeardDidChange(milliseconds: Int, percentage: Double) {
        eventSink?(["millisecondsHeardDidChange": ["milliseconds": milliseconds,
                                                   "percentage": percentage]])
    }

    public func playerDidFinishPlaying() {
        eventSink?("playerDidFinishPlaying")
    }
}

// MARK: - RecorderControllerDelegate

extension SwiftCarbonvoiceAudioPlugin: RecorderControllerDelegate {
    public func recordedTimeDidChange(secondsRecorded: Int) {
        eventSink?(["recordedTimeDidChange": ["secondsRecorded": secondsRecorded]])
    }
}
