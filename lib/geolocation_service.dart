import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:traccar_client/location_cache.dart';
import 'package:traccar_client/preferences.dart';
import 'package:wakelock_partial_android/wakelock_partial_android.dart';

class GeolocationService {
  static Future<void> init() async {
    await bg.BackgroundGeolocation.ready(Preferences.geolocationConfig());

    if (!_isWithinSchedule()) {
      await bg.BackgroundGeolocation.stop();
      bg.Logger.notice(
        "DEVLOG - Geolocation is outside of schedule and has been stopped.",
      );
      print(
        'DEVLOG - Geolocation is outside of schedule and has been stopped.',
      );
      return;
    }

    if (Platform.isAndroid) {
      await bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
    }
    bg.BackgroundGeolocation.onEnabledChange(onEnabledChange);
    bg.BackgroundGeolocation.onMotionChange(onMotionChange);
    bg.BackgroundGeolocation.onLocation(onLocation);
    bg.BackgroundGeolocation.onHeartbeat(onHeartbeat);
  }

  static Future<void> onEnabledChange(bool enabled) async {
    if (Preferences.instance.getBool(Preferences.wakelock) ?? false) {
      if (!enabled) {
        await WakelockPartialAndroid.release();
      }
    }
  }

  static Future<void> onMotionChange(bg.Location location) async {
    if (Preferences.instance.getBool(Preferences.wakelock) ?? false) {
      if (location.isMoving) {
        await WakelockPartialAndroid.acquire();
      } else {
        await WakelockPartialAndroid.release();
      }
    }
  }

  static Future<void> onLocation(bg.Location location) async {
    if (_shouldDelete(location)) {
      await bg.BackgroundGeolocation.destroyLocation(location.uuid);
    } else {
      LocationCache.set(location);
      try {
        await bg.BackgroundGeolocation.sync();
      } catch (error) {
        developer.log('Failed to send location', error: error);
      }
    }
  }

  static Future<void> onHeartbeat(bg.HeartbeatEvent event) async {
    if (_isWithinSchedule()) {
      final state = await bg.BackgroundGeolocation.state;
      if (!state.enabled) {
        await bg.BackgroundGeolocation.start();
        bg.Logger.notice("DEVLOG - Geolocation started (inside schedule)");
        print("DEVLOG - Geolocation started (inside schedule)");
      }
    } else {
      await bg.BackgroundGeolocation.stop();
      bg.Logger.warn("DEVLOG - Geolocation stopped (outside schedule)");
      print("DEVLOG - Geolocation stopped (outside schedule)");
      return;
    }

    await bg.BackgroundGeolocation.getCurrentPosition(
      samples: 1,
      persist: true,
      extras: {'heartbeat': true},
    );
  }

  static bool _shouldDelete(bg.Location location) {
    if (!location.isMoving) return false;
    if (location.extras?.isNotEmpty == true) return false;

    final lastLocation = LocationCache.get();
    if (lastLocation == null) return false;

    final isHighestAccuracy =
        Preferences.instance.getString(Preferences.accuracy) == 'highest';
    final duration =
        DateTime.parse(
          location.timestamp,
        ).difference(DateTime.parse(lastLocation.timestamp)).inSeconds;

    if (!isHighestAccuracy) {
      final fastestInterval = Preferences.instance.getInt(
        Preferences.fastestInterval,
      );
      if (fastestInterval != null && duration < fastestInterval) return true;
    }

    final distance = _distance(lastLocation, location);

    final distanceFilter =
        Preferences.instance.getInt(Preferences.distance) ?? 0;
    if (distanceFilter > 0 && distance >= distanceFilter) return false;

    if (distanceFilter == 0 || isHighestAccuracy) {
      final intervalFilter =
          Preferences.instance.getInt(Preferences.interval) ?? 0;
      if (intervalFilter > 0 && duration >= intervalFilter) return false;
    }

    if (isHighestAccuracy &&
        lastLocation.heading >= 0 &&
        location.coords.heading > 0) {
      final angle = (location.coords.heading - lastLocation.heading).abs();
      final angleFilter = Preferences.instance.getInt(Preferences.angle) ?? 0;
      if (angleFilter > 0 && angle >= angleFilter) return false;
    }

    return true;
  }

  static double _distance(Location from, bg.Location to) {
    const earthRadius = 6371008.8; // meters
    final dLat = _degToRad(to.coords.latitude - from.latitude);
    final dLon = _degToRad(to.coords.longitude - from.longitude);
    final sinLat = sin(dLat / 2);
    final sinLon = sin(dLon / 2);
    final a =
        sinLat * sinLat +
        cos(_degToRad(from.latitude)) *
            cos(_degToRad(to.coords.latitude)) *
            sinLon *
            sinLon;
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degToRad(double degree) => degree * pi / 180.0;

  static bool _isWithinSchedule() {
    final schedule = Preferences.loadSchedule();
    if (schedule == null) return true; // Default to always on if no schedule

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentWeekday = now.weekday; // Monday = 1, Sunday = 7

    final start = schedule.startTime;
    final stop = schedule.stopTime;

    final isDayAllowed = schedule.days.contains(currentWeekday);

    isTimeInRange() {
      final nowMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final stopMinutes = stop.hour * 60 + stop.minute;

      if (startMinutes < stopMinutes) {
        return nowMinutes >= startMinutes && nowMinutes <= stopMinutes;
      } else {
        // Overnight schedule (e.g., 22:00 to 06:00)
        return nowMinutes >= startMinutes || nowMinutes <= stopMinutes;
      }
    }

    print('DEVLOG - Day allowed: $isDayAllowed');
    print('DEVLOG - Time in rage: $isTimeInRange()');
    return isDayAllowed && isTimeInRange();
  }
}

@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent headlessEvent) async {
  await Preferences.init();
  switch (headlessEvent.name) {
    case bg.Event.ENABLEDCHANGE:
      await GeolocationService.onEnabledChange(headlessEvent.event);
      break;
    case bg.Event.MOTIONCHANGE:
      await GeolocationService.onMotionChange(headlessEvent.event);
      break;
    case bg.Event.LOCATION:
      await GeolocationService.onLocation(headlessEvent.event);
      break;
    case bg.Event.HEARTBEAT:
      await GeolocationService.onHeartbeat(headlessEvent.event);
      break;
  }
}
