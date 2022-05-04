import 'package:path_provider/path_provider.dart';

class AudioFile {
  static Future<String> getFilePath(String fileName, String extension) async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    return '${directory.path}/$fileName-$timestamp.$extension';
  }
}
