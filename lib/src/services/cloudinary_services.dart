import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> upload_img(File img) async {
  try {
    String cloudname = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    if (cloudname.isEmpty) throw 'CLOUDINARY_CLOUD_NAME no configurado en el .env';

    var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudname/raw/upload');
    var request = http.MultipartRequest('POST', uri);

    var fileBytes = await img.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: img.path.split("/").last,
    );

    request.files.add(multipartFile);
    request.fields['upload_preset'] = 'mentorme';
    request.fields['resource_type'] = 'raw';

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      return jsonMap['url'];
    } else {
      throw 'Error al subir la imagen: ${response.statusCode}';
    }
  } catch (e) {
    print('Error: $e');
    return '';
  }
}
