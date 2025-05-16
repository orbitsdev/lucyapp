class GameType {
  final int? id;
  final String? name;
  final String? code;
  final int? digitCount;
  final bool? isD4;
  
  GameType({
    this.id,
    this.name,
    this.code,
    this.digitCount,
    this.isD4,
  });
  
  factory GameType.fromJson(Map json) {
    // Extract digit count from code if not provided
    int? extractedDigitCount;
    if (json['digit_count'] == null && json['code'] != null) {
      final code = json['code'].toString();
      if (code.length >= 2 && (code.startsWith('S') || code.startsWith('D'))) {
        extractedDigitCount = int.tryParse(code.substring(1));
      }
    }
    
    return GameType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      digitCount: json['digit_count'] ?? extractedDigitCount,
      isD4: json['is_d4'] ?? (json['code'] == 'D4'),
    );
  }
  
  factory GameType.fromMap(Map map) {
    // Extract digit count from code if not provided
    int? extractedDigitCount;
    if (map['digit_count'] == null && map['code'] != null) {
      final code = map['code'].toString();
      if (code.length >= 2 && (code.startsWith('S') || code.startsWith('D'))) {
        extractedDigitCount = int.tryParse(code.substring(1));
      }
    }
    
    return GameType(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      digitCount: map['digit_count'] ?? extractedDigitCount,
      isD4: map['is_d4'] ?? (map['code'] == 'D4'),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'digit_count': digitCount,
      'is_d4': isD4 ?? (code == 'D4'),
    };
  }
  
  GameType copyWith({
    int? id,
    String? name,
    String? code,
    int? digitCount,
    bool? isD4,
  }) {
    return GameType(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      digitCount: digitCount ?? this.digitCount,
      isD4: isD4 ?? this.isD4,
    );
  }
  
  @override
  String toString() {
    return 'GameType(id: $id, name: $name, code: $code, digitCount: $digitCount, isD4: $isD4)';
  }
}
