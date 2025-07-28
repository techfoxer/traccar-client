import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_compress/video_compress.dart';

Future<File> compressImageFile(File file) async {
  final tempDir = await getTemporaryDirectory();
  final targetPath = p.join(
    tempDir.path,
    "${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(file.path)}.jpg",
  );

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70, // Adjust quality (0-100)
    format: CompressFormat.jpeg,
  );
  final compressed = result == null ? null : File(result.path);

  return compressed ?? file; // Fallback to original if compression fails
}

Future<File> compressVideoFile(File file) async {
  final info = await VideoCompress.compressVideo(
    file.path,
    quality:
        VideoQuality
            .MediumQuality, // Options: LowQuality, MediumQuality, HighQuality
    deleteOrigin: false, // Set to true if you want to delete the original video
  );

  return info?.file ?? file; // Fallback to original if compression fails
}
