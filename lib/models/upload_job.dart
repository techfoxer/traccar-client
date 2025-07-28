import 'dart:io';

class UploadJob {
  final String deliveryId;
  final String timestamp;
  final double lat;
  final double lng;
  String filePath;
  final String fileType;
  final String notes;
  final String signPath;
  final Map<String, dynamic> extra;

  UploadJob({
    required this.deliveryId,
    required this.timestamp,
    required this.lat,
    required this.lng,
    required this.filePath,
    required this.fileType,
    this.notes = '',
    required this.signPath,
    this.extra = const {},
  });

  Map<String, dynamic> toJson() => {
    'deliveryId': deliveryId,
    'timestamp': timestamp,
    'lat': lat,
    'lng': lng,
    'filePath': filePath,
    'fileType': fileType,
    'notes': notes,
    'signPath': signPath,
    'extra': extra,
  };

  static UploadJob fromJson(Map<String, dynamic> json) => UploadJob(
    deliveryId: json['deliveryId'],
    timestamp: json['timestamp'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    filePath: json['filePath'],
    fileType: json['fileType'],
    notes: json['notes'] ?? '',
    signPath: json['signPath'],
    extra: Map<String, dynamic>.from(json['extra'] ?? {}),
  );

  File get file => File(filePath);
  File get signature => File(signPath);
}
