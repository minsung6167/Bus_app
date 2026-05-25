class TerminalCoord {
  final double lat;
  final double lng;
  const TerminalCoord(this.lat, this.lng);
}

const _coords = <String, TerminalCoord>{
  '서울남부': TerminalCoord(37.4848, 127.0137),
  '서울경부': TerminalCoord(37.5051, 127.0052),
  '동서울': TerminalCoord(37.5346, 127.0954),
  '부산': TerminalCoord(35.1798, 129.0750),
  '대구': TerminalCoord(35.8892, 128.6163),
  '광주': TerminalCoord(35.1316, 126.9075),
  '대전': TerminalCoord(36.3482, 127.4341),
  '인천': TerminalCoord(37.4561, 126.7047),
  '수원': TerminalCoord(37.2636, 127.0276),
  '전주': TerminalCoord(35.8278, 127.1183),
  '창원': TerminalCoord(35.2375, 128.6894),
  '강릉': TerminalCoord(37.7519, 128.9008),
  '춘천': TerminalCoord(37.8713, 127.7397),
  '경주': TerminalCoord(35.8426, 129.2114),
  '여수': TerminalCoord(34.7439, 127.7378),
  '순천': TerminalCoord(34.9503, 127.4871),
  '목포': TerminalCoord(34.8118, 126.3928),
  '진주': TerminalCoord(35.1802, 128.1076),
  '울산': TerminalCoord(35.5347, 129.3125),
  '포항': TerminalCoord(36.0190, 129.3435),
  '안동': TerminalCoord(36.5655, 128.7294),
  '속초': TerminalCoord(38.2070, 128.5918),
  '고성': TerminalCoord(38.3798, 128.4668),
  '청주': TerminalCoord(36.6390, 127.4899),
  '원주': TerminalCoord(37.3420, 127.9207),
  '충주': TerminalCoord(36.9910, 127.9259),
  '천안': TerminalCoord(36.8153, 127.1139),
  '평택': TerminalCoord(36.9922, 127.0890),
  '구미': TerminalCoord(36.1195, 128.3446),
  '거제': TerminalCoord(34.8800, 128.6219),
  '제주': TerminalCoord(33.4890, 126.4983),
  '마산': TerminalCoord(35.2087, 128.5734),
  '통영': TerminalCoord(34.8547, 128.4335),
};

/// 터미널명에서 좌표를 찾는다. 완전일치 → 포함 순서로 탐색.
TerminalCoord? findCoord(String terminalName) {
  // 완전 일치
  if (_coords.containsKey(terminalName)) return _coords[terminalName];
  // 포함 탐색 (예: "서울남부터미널" → "서울남부")
  for (final entry in _coords.entries) {
    if (terminalName.contains(entry.key) || entry.key.contains(terminalName)) {
      return entry.value;
    }
  }
  return null;
}
