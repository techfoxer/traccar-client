import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/upload_job.dart';
import '../utils/compress_media.dart';

class UploadQueue extends GetxController {
  static const _storageKey = 'upload_queue';
  var _queue = <UploadJob>[];
  bool _isUploading = false;

  Future<void> _loadUploads() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];
    _queue = rawList.map((e) => UploadJob.fromJson(json.decode(e))).toList();
    if (_queue.isNotEmpty) {
      _startUpload(); // Start uploading if there are items in the queue
    }
  }

  @override
  void onInit() {
    _loadUploads();
    super.onInit();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _queue.map((job) => json.encode(job.toJson())).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  void addJob(UploadJob job) async {
    _queue.add(job);
    await _persist();
    _startUpload();
  }

  void _startUpload() {
    if (_isUploading || _queue.isEmpty) return;
    _isUploading = true;

    _uploadNext();
  }

  void _uploadNext() async {
    if (_queue.isEmpty) {
      _isUploading = false;
      return;
    }

    final job = _queue.first;

    try {
      File file = File(job.filePath);

      // Compress based on file type
      if (job.fileType == 'image') {
        file = await compressImageFile(file);
      } else if (job.fileType == 'video') {
        file = await compressVideoFile(file);
      }
      job.filePath = file.path;

      // Do compression for extra/dynamic fields
      for (final field in job.extra.entries) {
        if (field.value['type'] == 'photo') {
          job.extra[field.key]['value'] = await compressImageFile(
            File(field.value['value']),
          );
        }
      }

      // TODO: Upload to Firebase Storage or server

      _queue.removeAt(0);
      await _persist();
      _uploadNext(); // process next
    } catch (e) {
      print("DEVLOG - Upload failed, retrying...");
      Future.delayed(Duration(seconds: 10), _uploadNext);
    }
  }
}
