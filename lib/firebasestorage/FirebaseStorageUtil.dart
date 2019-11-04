import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseStorageUtil {
  static FirebaseStorageUtil _firebaseStorageUtil;

  factory FirebaseStorageUtil() =>
      _firebaseStorageUtil ?? FirebaseStorageUtil._();

  static const SEQ_IMAGES = 'sequence_images';
  static const CARDS = 'cards';
  static const CHIPS = 'chips';
  static const IMAGE = 'image';

  StorageReference _ref;

  FirebaseStorageUtil._() {
    _ref = FirebaseStorage.instance.ref();
  }

  Future<String> createDirIfNotExists(String folder) async {
    String appDir = (await getApplicationDocumentsDirectory()).path;
    String dirPath = '$appDir/' + folder;
    bool dirExists = await Directory(dirPath).exists();
    if (!dirExists) {
      await Directory(dirPath).create();
    }
    return dirPath;
  }

  Future<bool> checkIfFileExists(String path) async {
    return await File(path).exists();
  }

  Future<File> getFileFromStorage(String filename, String type) async {
    String dirPath = await createDirIfNotExists(type);

    String localFilePath = dirPath + '/' + filename;

    if (await checkIfFileExists(localFilePath)) {
      return File(localFilePath);
    } else {
      String storagePath;
      if (type == CARDS) {
        storagePath = SEQ_IMAGES + '/' + CARDS + '/' + filename;
      } else if (type == CHIPS) {
        storagePath = SEQ_IMAGES + '/' + CHIPS + '/' + filename;
      } else if (type == IMAGE) {
        storagePath = SEQ_IMAGES + '/' + IMAGE + '/' + filename;
      }
      if (null != storagePath) {
        File file = File(localFilePath);
        StorageReference reference = _ref.child(storagePath);
        reference.getDownloadURL();
        StorageFileDownloadTask downloadTask = reference.writeToFile(file);
        await downloadTask.future;
        return file;
      }
    }
    return null;
  }

  Future<String> getFileDownloadUrl(String filename, String type) async {
       String storagePath;
      if (type == CARDS) {
        storagePath = SEQ_IMAGES + '/' + CARDS + '/' + filename;
      } else if (type == CHIPS) {
        storagePath = SEQ_IMAGES + '/' + CHIPS + '/' + filename;
      } else if (type == IMAGE) {
        storagePath = SEQ_IMAGES + '/' + IMAGE + '/' + filename;
      }
      if (null != storagePath) {
        return await _ref.child(storagePath).getDownloadURL(); 
      }
      return null;
  }
}
