class AudioInput {
  String? name;
  String? port;

  static const DEFAULT_MIC = "DEFAULT";

  static AudioInput get none => AudioInput(name: DEFAULT_MIC, port: DEFAULT_MIC);

  AudioInput({this.name = DEFAULT_MIC, this.port = DEFAULT_MIC});
}
