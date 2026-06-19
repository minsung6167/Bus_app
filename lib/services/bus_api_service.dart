import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/bus_model.dart';
import '../models/terminal_model.dart';

class BusApiService {
  static const _baseUrl = 'http://apis.data.go.kr/1613000/SuburbsBusInfo';

  static String get _apiKey => dotenv.env['BUS_API_KEY'] ?? '';

  static List<Terminal>? _cachedTerminals;

  static Future<List<Terminal>> getTerminals() async {
    if (_cachedTerminals != null) return _cachedTerminals!;

    try {
      final all = <Terminal>[];
      int pageNo = 1;
      int totalCount = 0;
      const pageSize = 100;

      do {
        final uri = Uri.parse('$_baseUrl/GetSuberbsBusTrminlList').replace(
          queryParameters: {
            'serviceKey': _apiKey,
            'pageNo': '$pageNo',
            'numOfRows': '$pageSize',
            '_type': 'json',
          },
        );

        debugPrint('[API] 터미널 페이지$pageNo 요청');
        final response =
            await http.get(uri).timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) break;

        final data = json.decode(response.body);

        if (totalCount == 0) {
          totalCount = data['response']?['body']?['totalCount'] ?? 0;
          debugPrint('[API] 터미널 총 $totalCount개');
        }

        final items = _extractItems(data);
        if (items == null || items.isEmpty) break;

        all.addAll(items.map((e) => Terminal.fromJson(e)));
        pageNo++;
      } while (all.length < totalCount);

      if (all.isNotEmpty) {
        _cachedTerminals = all;
        debugPrint('[API] 터미널 ${all.length}개 로드 완료');
        for (final t in all) {
          debugPrint('  ${t.id} : ${t.name}');
        }
        return _cachedTerminals!;
      }
    } catch (e) {
      debugPrint('[API] 터미널 오류: $e');
    }

    debugPrint('[API] fallback 터미널 사용');
    return _fallbackTerminals;
  }

  static Future<List<Bus>> getSchedules({
    required String depTerminalId,
    required String arrTerminalId,
    required String depTerminalName,
    required String arrTerminalName,
    required DateTime date,
  }) async {
    final dateStr = DateFormat('yyyyMMdd').format(date);

    try {
      final uri =
          Uri.parse('$_baseUrl/GetStrtpntAlocFndSuberbsBusInfo').replace(
        queryParameters: {
          'serviceKey': _apiKey,
          'pageNo': '1',
          'numOfRows': '100',
          '_type': 'json',
          'depTerminalId': depTerminalId,
          'arrTerminalId': arrTerminalId,
          'depPlandTime': dateStr,
        },
      );

      debugPrint('[API] 스케줄 요청: ${uri.toString().replaceAll(_apiKey, '***')}');

      final response =
          await http.get(uri).timeout(const Duration(seconds: 5));

      debugPrint('[API] 스케줄 응답 코드: ${response.statusCode}');
      debugPrint('[API] 스케줄 응답(앞800자): ${response.body.substring(0, response.body.length.clamp(0, 800))}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resultCode = data['response']?['header']?['resultCode'];
        final totalCount = data['response']?['body']?['totalCount'] ?? 0;
        debugPrint('[API] 스케줄 resultCode: $resultCode, totalCount: $totalCount');

        final items = _extractItems(data);
        debugPrint('[API] 파싱된 아이템 수: ${items?.length ?? 0}');
        if (items != null && items.isNotEmpty) {
          final buses = items
              .map((e) => _scheduleToBus(e, depTerminalName, arrTerminalName))
              .toList();
          debugPrint('[API] ${buses.length}편 파싱 완료');
          return buses;
        }
      }
    } catch (e, st) {
      debugPrint('[API] 스케줄 오류: $e\n$st');
    }

    debugPrint('[API] fallback 스케줄 사용');
    return _fallbackSchedules(
      depTerminalId: depTerminalId,
      arrTerminalId: arrTerminalId,
      depTerminalName: depTerminalName,
      arrTerminalName: arrTerminalName,
      date: date,
    );
  }

  static Bus _scheduleToBus(
    Map<String, dynamic> json,
    String from,
    String to,
  ) {
    final depTime = _parseTime(json['depPlandTime']?.toString());
    final arrTime = _parseTime(json['arrPlandTime']?.toString());
    final gradeNm = json['gradeNm']?.toString() ?? '일반';
    final busType = switch (gradeNm) {
      '우등' => '우등',
      '프리미엄' => '프리미엄',
      _ => '일반',
    };
    final totalSeats = switch (busType) {
      '우등' => 27,
      '프리미엄' => 21,
      _ => 44,
    };
    final routeId = json['routeId']?.toString() ?? '';
    final remaining = _calcRemaining(totalSeats, depTime, routeId);

    final depPlandTime = json['depPlandTime']?.toString() ?? '';
    return Bus(
      id: '${routeId}_$depPlandTime'.isNotEmpty
          ? '${routeId}_$depPlandTime'
          : DateTime.now().millisecondsSinceEpoch.toString(),
      from: json['depPlaceNm']?.toString() ?? from,
      to: json['arrPlaceNm']?.toString() ?? to,
      departureTime: depTime,
      arrivalTime: arrTime,
      price: int.tryParse(json['charge']?.toString() ?? '0') ?? 0,
      totalSeats: totalSeats,
      remainingSeats: remaining,
      busType: busType,
      company: '',
    );
  }

  // routeId + 날짜 기반 결정론적 잔여석 계산 (같은 노선/날짜 = 항상 같은 값)
  static int _calcRemaining(int total, DateTime dep, String routeId) {
    final seed = routeId.hashCode ^
        dep.year ^
        (dep.month << 8) ^
        (dep.day << 16) ^
        (dep.hour << 20);
    final rng = Random(seed);

    final hour = dep.hour;
    final weekday = dep.weekday; // 1=월 ~ 7=일

    double occupancyRate;
    if (weekday == 5 || weekday == 7) {
      // 금요일·일요일: 혼잡
      if (hour >= 15 && hour <= 21) {
        occupancyRate = 0.75 + rng.nextDouble() * 0.22; // 75~97%
      } else {
        occupancyRate = 0.55 + rng.nextDouble() * 0.30; // 55~85%
      }
    } else if (weekday == 6) {
      // 토요일
      occupancyRate = 0.50 + rng.nextDouble() * 0.35; // 50~85%
    } else if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
      // 평일 출퇴근
      occupancyRate = 0.50 + rng.nextDouble() * 0.35; // 50~85%
    } else if (hour >= 22 || hour <= 6) {
      // 심야·새벽
      occupancyRate = 0.10 + rng.nextDouble() * 0.30; // 10~40%
    } else {
      // 평일 낮
      occupancyRate = 0.20 + rng.nextDouble() * 0.40; // 20~60%
    }

    final occupied = (total * occupancyRate).round().clamp(0, total);
    return (total - occupied).clamp(0, total);
  }

  // 형식: YYYYMMDDHHmm (12자리), API 시간은 KST(UTC+9)
  static DateTime _parseTime(String? raw) {
    if (raw == null || raw.length < 12) return DateTime.now();
    try {
      // UTC로 변환 후 로컬 시간으로: 기기 타임존과 무관하게 KST 기준 정확
      return DateTime.utc(
        int.parse(raw.substring(0, 4)),
        int.parse(raw.substring(4, 6)),
        int.parse(raw.substring(6, 8)),
        int.parse(raw.substring(8, 10)) - 9,
        int.parse(raw.substring(10, 12)),
      ).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  static List<Map<String, dynamic>>? _extractItems(dynamic data) {
    try {
      final body = data['response']['body'];
      final rawItems = body['items'];

      // items가 빈 문자열이면 결과 없음
      if (rawItems is String) return null;

      // items.item 구조 (표준 공공데이터 형식)
      if (rawItems is Map) {
        final item = rawItems['item'];
        if (item is List) return item.cast<Map<String, dynamic>>();
        if (item is Map) return [item.cast<String, dynamic>()];
      }

      // items가 직접 List인 경우
      if (rawItems is List) return rawItems.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[API] _extractItems 파싱 오류: $e');
    }
    return null;
  }

  static List<Bus> _fallbackSchedules({
    required String depTerminalId,
    required String arrTerminalId,
    required String depTerminalName,
    required String arrTerminalName,
    required DateTime date,
  }) {
    final seed = depTerminalId.hashCode ^ arrTerminalId.hashCode ^ date.day;
    final rng = Random(seed);

    // 노선 거리 추정 (터미널 ID 기반 해시로 결정론적 가격)
    final basePrice = 8000 + (rng.nextInt(8) * 3000); // 8,000~29,000원
    final baseDuration = 60 + rng.nextInt(180); // 1~4시간

    // 하루 시간대별 출발 편 생성
    final departureTimes = [
      6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    ];

    final buses = <Bus>[];
    for (final hour in departureTimes) {
      final minute = [0, 10, 20, 30, 40, 50][rng.nextInt(6)];
      final dep = DateTime(date.year, date.month, date.day, hour, minute);
      final arr = dep.add(Duration(minutes: baseDuration));

      final types = ['일반', '일반', '일반', '우등', '우등', '프리미엄'];
      final busType = types[rng.nextInt(types.length)];
      final totalSeats = busType == '프리미엄' ? 21 : busType == '우등' ? 27 : 44;
      final priceMultiplier = busType == '프리미엄' ? 1.5 : busType == '우등' ? 1.2 : 1.0;
      final price = (basePrice * priceMultiplier).round();

      buses.add(Bus(
        id: '${depTerminalId}_${arrTerminalId}_${dep.millisecondsSinceEpoch}',
        from: depTerminalName,
        to: arrTerminalName,
        departureTime: dep,
        arrivalTime: arr,
        price: price,
        totalSeats: totalSeats,
        remainingSeats: _calcRemaining(totalSeats, dep, depTerminalId + arrTerminalId),
        busType: busType,
        company: '',
      ));
    }
    return buses;
  }

  static List<Terminal> get _fallbackTerminals => const [
        Terminal(id: 'NAI0671801', name: '서울남부', cityName: '서울'),
        Terminal(id: 'NAI0511601', name: '동서울', cityName: '서울'),
        Terminal(id: 'NAI0215101', name: '상봉', cityName: '서울'),
        Terminal(id: 'NAI0670601', name: '서울고속버스터미널(경부)', cityName: '서울'),
        Terminal(id: 'NAI0670701', name: '서울고속버스터미널(호남)', cityName: '서울'),
        Terminal(id: 'NAI4620301', name: '부산종합', cityName: '부산'),
        Terminal(id: 'NAI4696901', name: '부산서부(사상)', cityName: '부산'),
        Terminal(id: 'NAI4620401', name: '부산동부', cityName: '부산'),
        Terminal(id: 'NAI4248201', name: '대구서부', cityName: '대구'),
        Terminal(id: 'NAI6193701', name: '광주(유·스퀘어)', cityName: '광주'),
        Terminal(id: 'NAI3455101', name: '대전복합', cityName: '대전'),
        Terminal(id: 'NAI4472001', name: '울산', cityName: '울산'),
        Terminal(id: 'NAI2224201', name: '인천', cityName: '인천'),
        Terminal(id: 'NAI1658501', name: '수원터미널', cityName: '수원'),
        Terminal(id: 'NAI2443501', name: '춘천', cityName: '춘천'),
        Terminal(id: 'NAI5493301', name: '전주시외터미널', cityName: '전주'),
        Terminal(id: 'NAI2839701', name: '청주', cityName: '청주'),
        Terminal(id: 'NAI2551901', name: '강릉', cityName: '강릉'),
        Terminal(id: 'NAI2482701', name: '속초', cityName: '속초'),
        Terminal(id: 'NAI5302001', name: '통영터미널', cityName: '통영'),
        Terminal(id: 'NAI5275901', name: '진주', cityName: '진주'),
        Terminal(id: 'NAI5796001', name: '순천', cityName: '순천'),
        Terminal(id: 'NAI5864201', name: '목포', cityName: '목포'),
      ];
}
