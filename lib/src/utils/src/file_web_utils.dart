import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

// Class utils just to be able to instantiate a file
// and do not receive the error
class FileUtils {
  static Future<List<int>> getFileBytes(String url) async {
    final result = await http.get(Uri.parse(url));
    return result.bodyBytes.toList();
  }

  // static Future<File?> getFileFromImageUrl(String url) async {
  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     final documentDirectory = await getApplicationDocumentsDirectory();

  //     final file = File(join(documentDirectory.path, url.split('/').last));

  //     file.writeAsBytesSync(response.bodyBytes);

  //     return file;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<Uint8List?> getBytesFromWebUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  static void downloadFile(String? url) {
    html.window.open(url ?? "", url?.split("/").last ?? 'PlaceholderName');

    // html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    // anchorElement.download = url;
    // anchorElement.click();
  }
}
