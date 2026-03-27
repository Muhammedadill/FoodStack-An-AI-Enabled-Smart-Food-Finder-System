import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dj1yxmphj';
  static const String apiKey = 'Cv3S9uPYfvJJsOuDbuq_a_n3vlU';
  static const String uploadPreset = 'ugwklmdu';

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  /// Upload a file (image or video) to Cloudinary.
  /// Returns the secure URL of the uploaded file.
  /// [filePath] - absolute path to the file on device.
  /// [folder] - optional folder name in Cloudinary (e.g. 'food_images', 'reels').
  static Future<String?> uploadFile(
    String filePath, {
    String folder = 'food_stack',
  }) async {
    try {
      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'] as String?;
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            'Cloudinary upload failed (${response.statusCode}): $responseBody');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  /// Upload an image file and return the URL.
  static Future<String?> uploadImage(String filePath) async {
    return uploadFile(filePath, folder: 'food_stack/images');
  }

  /// Upload a video file and return the URL.
  static Future<String?> uploadVideo(String filePath) async {
    return uploadFile(filePath, folder: 'food_stack/videos');
  }
}
