import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startSleepModeCallback() {
  FlutterForegroundTask.setTaskHandler(SleepModeTaskHandler());
}

class SleepModeTaskHandler extends TaskHandler {
  double? _destLat;
  double? _destLng;
  double _alertMeters = 2000;
  bool _triggered = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    _destLat = prefs.getDouble('sleep_dest_lat');
    _destLng = prefs.getDouble('sleep_dest_lng');
    _alertMeters = prefs.getDouble('sleep_alert_meters') ?? 2000;
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (_triggered || _destLat == null || _destLng == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final dist = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, _destLat!, _destLng!,
      );
      final distKm = (dist / 1000).toStringAsFixed(1);

      FlutterForegroundTask.updateService(
        notificationTitle: '수면 모드 중 🌙',
        notificationText: '목적지까지 약 ${distKm}km 남았습니다',
      );

      if (dist <= _alertMeters) {
        _triggered = true;
        FlutterForegroundTask.sendDataToMain(<String, dynamic>{
          'action': 'wake_up',
          'dist': dist,
        });
      }
    } catch (_) {}
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {}
}

void initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'sleep_mode_channel',
      channelName: '수면 모드',
      channelDescription: 'GPS 기반 도착 알림 서비스',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(15000), // 15초마다
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}
