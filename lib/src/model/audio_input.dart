class AudioInput {
  String? name;
  String? port;

  static AudioInput get none => AudioInput(name: "None", port: "none");

  AudioInput({this.name, this.port});
}
