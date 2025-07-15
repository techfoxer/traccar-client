import 'dart:math';

import 'package:intl/intl.dart';

DateFormat mdFormat = DateFormat('MMM dd');
DateFormat yMonthDFormat = DateFormat('MMMM dd yyyy');
DateFormat mmmdyFormat = DateFormat('dd MMM yyyy');
DateFormat mdyFormat = DateFormat('MM/dd/yyyy');
DateFormat dmyFormat = DateFormat('dd/MM/yyyy');
DateFormat ymdFormat = DateFormat('yyyy-MM-dd');
DateFormat dayFormat = DateFormat('EEE');
DateFormat dayTimeFormat = DateFormat('EEE, dd MMMM yyyy hh:mm:ss a');
DateFormat myFormat = DateFormat('MMMM yyyy');
DateFormat hmFormat = DateFormat('hh:mm a');
DateFormat hourFormat = DateFormat('hha');

RegExp DECIMAL_NUMBERS = RegExp(r'(^\d*\.?\d*)');
RegExp NUMBERS = RegExp(r'[0-9]');

formattedCurrency(num amount, {bool decimal = false}) {
  if (amount > 99999) {
    return NumberFormat.compact().format(amount);
  } else {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: decimal ? 2 : 0,
    ).format(amount);
  }
}

bool isThisMonth(DateTime dateTime) {
  return DateTime.now().toUtc().year == dateTime.year &&
      dateTime.month == DateTime.now().toUtc().month;
}

bool isSameDay(DateTime first, DateTime second) {
  return second.year == first.year &&
      first.month == second.month &&
      first.day == second.day;
}

final emailRegex = RegExp(
  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
);
final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

extension StringExt on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/// Calculates the distance in kilometers between two latitude/longitude points
double calculateDistance({
  required double startLat,
  required double startLon,
  required double endLat,
  required double endLon,
}) {
  const double earthRadius = 6371; // Earth's radius in KM

  double dLat = _degreesToRadians(endLat - startLat);
  double dLon = _degreesToRadians(endLon - startLon);

  double a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(startLat)) *
          cos(_degreesToRadians(endLat)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in KM
}

/// Converts degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

/// Returns a human-readable time difference like "just now", "2 minutes ago", etc.
/// [milliseconds] is expected to be in Unix epoch time (milliseconds since 1970).
String timeAgo(int milliseconds) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final diff = now.difference(date);

  if (diff.inSeconds < 60) {
    return 'just now';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  } else if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (diff.inDays < 365) {
    final months = (diff.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (diff.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}

String timeAgo2(int milliseconds) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final diff = now.difference(date);

  if (diff.inSeconds < 60) {
    return 'just now';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return hmFormat.format(date);
  }
}

/// Is today
bool isToday(DateTime date) {
  return date.year == DateTime.now().year &&
      date.month == DateTime.now().month &&
      date.day == DateTime.now().day;
}

/// Is in past
bool isPast(DateTime date) {
  return date.isBefore(DateTime.now());
}

String generateReferralCode({int length = 6}) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}
