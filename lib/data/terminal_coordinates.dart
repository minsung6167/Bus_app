class TerminalCoord {
  final double lat;
  final double lng;
  const TerminalCoord(this.lat, this.lng);
}

const _coords = <String, TerminalCoord>{
  // ── 서울/수도권 ──────────────────────────────
  '서울남부': TerminalCoord(37.4855, 127.0151),
  '서울경부': TerminalCoord(37.5049, 127.0052),
  '서울고속버스터미널(경부)': TerminalCoord(37.5049, 127.0052),
  '서울고속버스터미널(호남)': TerminalCoord(37.5046, 127.0063),
  '동서울': TerminalCoord(37.5348, 127.0944),
  '상봉': TerminalCoord(37.5960, 127.0921),
  '수원': TerminalCoord(37.2987, 127.0076),
  '수원터미널': TerminalCoord(37.2987, 127.0076),
  '인천': TerminalCoord(37.4561, 126.7047),
  '성남': TerminalCoord(37.4386, 127.1379),
  '이천': TerminalCoord(37.2783, 127.4425),
  '평택': TerminalCoord(36.9922, 127.0890),
  '천안': TerminalCoord(36.8153, 127.1139),

  // ── 부산 ─────────────────────────────────────
  '부산': TerminalCoord(35.2568, 129.0862),        // 노포 종합터미널
  '부산종합': TerminalCoord(35.2568, 129.0862),
  '부산서부(사상)': TerminalCoord(35.1556, 128.9975),
  '부산동부': TerminalCoord(35.1943, 129.1279),

  // ── 대구 ─────────────────────────────────────
  '대구': TerminalCoord(35.9099, 128.5896),        // 대구북부터미널
  '대구북부': TerminalCoord(35.9099, 128.5896),
  '대구서부': TerminalCoord(35.8673, 128.5726),

  // ── 광주 ─────────────────────────────────────
  '광주': TerminalCoord(35.1553, 126.8994),        // 유스퀘어
  '광주(유·스퀘어)': TerminalCoord(35.1553, 126.8994),

  // ── 대전 ─────────────────────────────────────
  '대전': TerminalCoord(36.3593, 127.3850),        // 대전복합터미널
  '대전복합': TerminalCoord(36.3593, 127.3850),

  // ── 기타 주요 도시 ────────────────────────────
  '울산': TerminalCoord(35.5347, 129.3125),
  '전주': TerminalCoord(35.8278, 127.1183),
  '전주시외터미널': TerminalCoord(35.8278, 127.1183),
  '청주': TerminalCoord(36.6390, 127.4899),
  '원주': TerminalCoord(37.3420, 127.9207),
  '강릉': TerminalCoord(37.7519, 128.9008),
  '춘천': TerminalCoord(37.8713, 127.7397),
  '속초': TerminalCoord(38.2070, 128.5918),
  '고성': TerminalCoord(38.3798, 128.4668),
  '충주': TerminalCoord(36.9910, 127.9259),
  '안동': TerminalCoord(36.5655, 128.7294),
  '포항': TerminalCoord(36.0190, 129.3435),
  '경주': TerminalCoord(35.8426, 129.2114),
  '구미': TerminalCoord(36.1195, 128.3446),
  '창원': TerminalCoord(35.2375, 128.6894),
  '마산': TerminalCoord(35.2087, 128.5734),
  '진주': TerminalCoord(35.1802, 128.1076),
  '통영': TerminalCoord(34.8547, 128.4335),
  '통영터미널': TerminalCoord(34.8547, 128.4335),
  '거제': TerminalCoord(34.8800, 128.6219),
  '순천': TerminalCoord(34.9503, 127.4871),
  '여수': TerminalCoord(34.7439, 127.7378),
  '목포': TerminalCoord(34.8118, 126.3928),
  '제주': TerminalCoord(33.4890, 126.4983),
};

/// 터미널명에서 좌표를 찾는다. 완전일치 → 포함(긴 키 우선) 순서로 탐색.
TerminalCoord? findCoord(String terminalName) {
  // 완전 일치
  if (_coords.containsKey(terminalName)) return _coords[terminalName];

  // 포함 탐색 - 더 구체적인(긴) 키를 우선해서 오매칭 방지
  final candidates = _coords.entries
      .where((e) =>
          terminalName.contains(e.key) || e.key.contains(terminalName))
      .toList()
    ..sort((a, b) => b.key.length.compareTo(a.key.length));

  if (candidates.isNotEmpty) return candidates.first.value;
  return null;
}
