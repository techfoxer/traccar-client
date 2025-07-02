import 'package:flutter/material.dart';

class ServiceSchedule {
  final TimeOfDay startTime;
  final TimeOfDay stopTime;
  final List<int> days; // 1 = Monday, 7 = Sunday

  ServiceSchedule({
    required this.startTime,
    required this.stopTime,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
    'startTime': '${startTime.hour}:${startTime.minute}',
    'stopTime': '${stopTime.hour}:${stopTime.minute}',
    'days': days,
  };

  static ServiceSchedule fromJson(Map<String, dynamic> json) {
    final startParts = (json['startTime'] as String).split(':');
    final stopParts = (json['stopTime'] as String).split(':');
    return ServiceSchedule(
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      stopTime: TimeOfDay(
        hour: int.parse(stopParts[0]),
        minute: int.parse(stopParts[1]),
      ),
      days: List<int>.from(json['days']),
    );
  }
}
