import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MediaUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<List<String>> uploadFiles(List<File> files, String folderName) async {
    List<String> downloadUrls = [];

    for (File file in files) {
      final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
      final ref = _storage.ref().child('$folderName/$fileName');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }
}
