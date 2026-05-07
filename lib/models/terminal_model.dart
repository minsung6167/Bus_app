class Terminal {
  final String id;
  final String name;
  final String cityName;

  const Terminal({
    required this.id,
    required this.name,
    required this.cityName,
  });

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      id: json['terminalId']?.toString() ?? '',
      name: json['terminalNm']?.toString() ?? '',
      cityName: (json['cityName'] ?? json['cityNm'])?.toString() ?? '',
    );
  }

  @override
  String toString() => name;
}
