// image_helper.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<String?> uploadImage(File image) async {
  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('wine_images/$imageName.jpg');

    // Compress and resize the image
    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 80, // Adjust the quality as needed (0 to 100)
      minWidth: 800, // Set the maximum width of the image
      minHeight: 800, // Set the maximum height of the image
    );

    if (compressedImage != null) {
      // Upload the compressed image
      UploadTask uploadTask = ref.putData(compressedImage);

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } else {
      // Handle the case where image compression fails
      return null;
    }
  } catch (e) {
    // Handle error gracefully
    return null;
  }
}

Future<void> deleteImage(String imageUrl) async {
  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.refFromURL(imageUrl);
    await ref.delete();
  } catch (e) {
    if (kDebugMode) {
      print('Error deleting image: $e');
    }
    // Handle error gracefully
  }
}
