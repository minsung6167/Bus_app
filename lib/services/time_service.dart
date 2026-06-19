import 'package:flutter/foundation.dart';
import 'package:ntp/ntp.dart';

class TimeService {
  static int _offsetMs = 0;

  static Future<void> init() async {
    try {
      _offsetMs = await NTP.getNtpOffset(
        localTime: DateTime.now(),
        timeout: const Duration(seconds: 5),
      );
      debugPrint('[Time] NTP 오프셋: ${_offsetMs}ms');
    } catch (e) {
      debugPrint('[Time] NTP 실패, 기기 시간 사용: $e');
    }
  }

  static DateTime now() =>
      DateTime.now().add(Duration(milliseconds: _offsetMs));
}
