class AudioInput {
  String? name;
  String? port;

  static AudioInput get none => AudioInput(name: "Unknown", port: "Unknown");

  AudioInput({this.name, this.port});
}
