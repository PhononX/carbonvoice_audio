import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<List<int>> getFileBytes(String path) async {
    var file = File(path);
    return await file.readAsBytes();
  }

  static Future<Uint8List?> getBytesFromWebUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> createFileFromBytes(
    List<int> bytes, {
    String fileName = "temp",
    String ext = "temp",
    int? reWidth,
    int? reHeight,
  }) async {
    try {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var directory = await getApplicationDocumentsDirectory();
      String path = '${directory.path}/$fileName-$timestamp.$ext';
      File file = await (File(path).create());
      file = await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      return null;
    }
  }

  static void downloadFile(String url) {
    print("fake downloadFile");
  }
}
