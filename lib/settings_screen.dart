import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:traccar_client/geolocation_service.dart';
import 'package:traccar_client/main.dart';
import 'package:traccar_client/password_service.dart';
import 'package:traccar_client/qr_code_screen.dart';
import 'package:wakelock_partial_android/wakelock_partial_android.dart';

import 'l10n/app_localizations.dart';
import 'models/schedule.dart';
import 'preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool advanced = false;
  List<String> reorderedWeekdays = [];
  String _getAccuracyLabel(String? key) {
    return switch (key) {
      'highest' => AppLocalizations.of(context)!.highestAccuracyLabel,
      'high' => AppLocalizations.of(context)!.highAccuracyLabel,
      'low' => AppLocalizations.of(context)!.lowAccuracyLabel,
      _ => AppLocalizations.of(context)!.mediumAccuracyLabel,
    };
  }

  Future<void> _editSetting(String title, String key, bool isInt) async {
    final initialValue =
        isInt
            ? Preferences.instance.getInt(key)?.toString() ?? '0'
            : Preferences.instance.getString(key) ?? '';

    final controller = TextEditingController(text: initialValue);
    final errorMessage = AppLocalizations.of(context)!.invalidValue;

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              keyboardType: isInt ? TextInputType.number : TextInputType.text,
              inputFormatters:
                  isInt ? [FilteringTextInputFormatter.digitsOnly] : [],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(AppLocalizations.of(context)!.saveButton),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      if (key == Preferences.url) {
        final uri = Uri.tryParse(result);
        if (uri == null ||
            uri.host.isEmpty ||
            !(uri.scheme == 'http' || uri.scheme == 'https')) {
          messengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          return;
        }
      }
      if (isInt) {
        int? intValue = int.tryParse(result);
        if (intValue != null) {
          if (key == Preferences.heartbeat && intValue > 0 && intValue < 60) {
            intValue = 60; // minimum heartbeat is 60 seconds
          }
          await Preferences.instance.setInt(key, intValue);
        }
      } else {
        await Preferences.instance.setString(key, result);
      }
      await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
      setState(() {});
    }
  }

  Future<void> _changePassword() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordLabel,
              ),
              obscureText: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.saveButton),
              ),
            ],
          ),
    );
    if (result == true) {
      await PasswordService.setPassword(controller.text);
    }
  }

  Widget _buildListTile(String title, String key, bool isInt) {
    String? value;
    if (isInt) {
      final intValue = Preferences.instance.getInt(key);
      if (intValue != null && intValue > 0) {
        value = intValue.toString();
      } else {
        value = AppLocalizations.of(context)!.disabledValue;
      }
    } else {
      value = Preferences.instance.getString(key);
    }
    return ListTile(
      title: Text(title),
      subtitle: Text(value ?? ''),
      onTap: () => _editSetting(title, key, isInt),
    );
  }

  Widget _buildAccuracyListTile() {
    final accuracyOptions = ['highest', 'high', 'medium', 'low'];
    return ListTile(
      title: Text(AppLocalizations.of(context)!.accuracyLabel),
      subtitle: Text(
        _getAccuracyLabel(Preferences.instance.getString(Preferences.accuracy)),
      ),
      onTap: () async {
        final selectedAccuracy = await showDialog<String>(
          context: context,
          builder:
              (context) => SimpleDialog(
                title: Text(AppLocalizations.of(context)!.accuracyLabel),
                children:
                    accuracyOptions
                        .map(
                          (option) => SimpleDialogOption(
                            child: Text(_getAccuracyLabel(option)),
                            onPressed: () => Navigator.pop(context, option),
                          ),
                        )
                        .toList(),
              ),
        );
        if (selectedAccuracy != null) {
          await Preferences.instance.setString(
            Preferences.accuracy,
            selectedAccuracy,
          );
          await bg.BackgroundGeolocation.setConfig(
            Preferences.geolocationConfig(),
          );
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEVLOG - Weekday: ${DateTime.now().weekday}');
    final localizedWeekdays = MaterialLocalizations.of(context).narrowWeekdays;
    reorderedWeekdays = [
      localizedWeekdays[1], // Monday
      localizedWeekdays[2], // Tuesday
      localizedWeekdays[3], // Wednesday
      localizedWeekdays[4], // Thursday
      localizedWeekdays[5], // Friday
      localizedWeekdays[6], // Saturday
      localizedWeekdays[0], // Sunday
    ];
    final isHighestAccuracy =
        Preferences.instance.getString(Preferences.accuracy) == 'highest';
    final distance = Preferences.instance.getInt(Preferences.distance);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrCodeScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildListTile(
            AppLocalizations.of(context)!.idLabel,
            Preferences.id,
            false,
          ),
          _buildListTile(
            AppLocalizations.of(context)!.urlLabel,
            Preferences.url,
            false,
          ),
          _buildAccuracyListTile(),
          _buildListTile(
            AppLocalizations.of(context)!.distanceLabel,
            Preferences.distance,
            true,
          ),
          if (isHighestAccuracy || Platform.isAndroid && distance == 0)
            _buildListTile(
              AppLocalizations.of(context)!.intervalLabel,
              Preferences.interval,
              true,
            ),
          if (isHighestAccuracy)
            _buildListTile(
              AppLocalizations.of(context)!.angleLabel,
              Preferences.angle,
              true,
            ),
          _buildListTile(
            AppLocalizations.of(context)!.heartbeatLabel,
            Preferences.heartbeat,
            true,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.scheduleLabel),
            subtitle: Builder(
              builder: (_) {
                final schedule = Preferences.loadSchedule();
                if (schedule == null) {
                  return Text(AppLocalizations.of(context)!.notSetLabel);
                }
                final start = schedule.startTime.format(context);
                final stop = schedule.stopTime.format(context);
                final days = schedule.days
                    .map((d) => reorderedWeekdays[d - 1])
                    .join(', ');
                return Text('$start - $stop ($days)');
              },
            ),
            onTap: _editSchedule,
          ),

          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.advancedLabel),
            value: advanced,
            onChanged: (value) {
              setState(() => advanced = value);
            },
          ),
          if (advanced)
            _buildListTile(
              AppLocalizations.of(context)!.fastestIntervalLabel,
              Preferences.fastestInterval,
              true,
            ),
          if (advanced)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.bufferLabel),
              value: Preferences.instance.getBool(Preferences.buffer) ?? true,
              onChanged: (value) async {
                await Preferences.instance.setBool(Preferences.buffer, value);
                await bg.BackgroundGeolocation.setConfig(
                  Preferences.geolocationConfig(),
                );
                setState(() {});
              },
            ),
          if (advanced && Platform.isAndroid)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.wakelockLabel),
              value:
                  Preferences.instance.getBool(Preferences.wakelock) ?? false,
              onChanged: (value) async {
                await Preferences.instance.setBool(Preferences.wakelock, value);
                if (value) {
                  final state = await bg.BackgroundGeolocation.state;
                  if (state.isMoving == true) {
                    WakelockPartialAndroid.acquire();
                  }
                } else {
                  WakelockPartialAndroid.release();
                }
                setState(() {});
              },
            ),
          if (advanced)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.stopDetectionLabel),
              value:
                  Preferences.instance.getBool(Preferences.stopDetection) ??
                  true,
              onChanged: (value) async {
                await Preferences.instance.setBool(
                  Preferences.stopDetection,
                  value,
                );
                await bg.BackgroundGeolocation.setConfig(
                  Preferences.geolocationConfig(),
                );
                setState(() {});
              },
            ),
          if (advanced)
            ListTile(
              title: Text(AppLocalizations.of(context)!.passwordLabel),
              onTap: _changePassword,
            ),
        ],
      ),
    );
  }

  Future<void> _editSchedule() async {
    ServiceSchedule? current = Preferences.loadSchedule();

    TimeOfDay start = current?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay stop = current?.stopTime ?? const TimeOfDay(hour: 17, minute: 0);
    List<int> selectedDays = current?.days ?? [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.scheduleLabel),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        '${AppLocalizations.of(context)!.startLabel}: ${start.format(context)}',
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: start,
                        );
                        if (picked != null) setModalState(() => start = picked);
                      },
                    ),
                    ListTile(
                      title: Text(
                        '${AppLocalizations.of(context)!.stopLabel}: ${stop.format(context)}',
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: stop,
                        );
                        if (picked != null) setModalState(() => stop = picked);
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(reorderedWeekdays[index]),
                          selected: isSelected,
                          onSelected: (_) {
                            setModalState(() {
                              print('DEVLOG - Day: $day');
                              if (isSelected) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancelButton),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.saveButton),
                  onPressed: () async {
                    Preferences.saveSchedule(
                      ServiceSchedule(
                        startTime: start,
                        stopTime: stop,
                        days: selectedDays,
                      ),
                    );
                    Navigator.pop(context);
                    setState(() {}); // update UI
                    await bg.BackgroundGeolocation.stop();
                    await GeolocationService.init();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
