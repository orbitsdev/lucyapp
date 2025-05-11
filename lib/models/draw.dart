class Draw {
  final int? id;
  final String? drawDate;
  final String? drawDateFormatted;
  final String? drawTime;
  final String? drawTimeFormatted;
  final String? drawTimeSimple;
  final bool? isOpen;
  final bool? isActive;
  
  Draw({
    this.id,
    this.drawDate,
    this.drawDateFormatted,
    this.drawTime,
    this.drawTimeFormatted,
    this.drawTimeSimple,
    this.isOpen,
    this.isActive,
  });
  
  factory Draw.fromJson(Map json) {
    return Draw(
      id: json['id'],
      drawDate: json['draw_date']?.toString(),
      drawDateFormatted: json['draw_date_formatted']?.toString(),
      drawTime: json['draw_time']?.toString(),
      drawTimeFormatted: json['draw_time_formatted']?.toString(),
      drawTimeSimple: json['draw_time_simple']?.toString(),
      isOpen: json['is_open'],
      isActive: json['is_active'],
    );
  }
  
  factory Draw.fromMap(Map map) {
    return Draw(
      id: map['id'],
      drawDate: map['draw_date']?.toString(),
      drawDateFormatted: map['draw_date_formatted']?.toString(),
      drawTime: map['draw_time']?.toString(),
      drawTimeFormatted: map['draw_time_formatted']?.toString(),
      drawTimeSimple: map['draw_time_simple']?.toString(),
      isOpen: map['is_open'],
      isActive: map['is_active'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'draw_date': drawDate,
      'draw_date_formatted': drawDateFormatted,
      'draw_time': drawTime,
      'draw_time_formatted': drawTimeFormatted,
      'draw_time_simple': drawTimeSimple,
      'is_open': isOpen,
      'is_active': isActive,
    };
  }
  
  Draw copyWith({
    int? id,
    String? drawDate,
    String? drawDateFormatted,
    String? drawTime,
    String? drawTimeFormatted,
    String? drawTimeSimple,
    bool? isOpen,
    bool? isActive,
  }) {
    return Draw(
      id: id ?? this.id,
      drawDate: drawDate ?? this.drawDate,
      drawDateFormatted: drawDateFormatted ?? this.drawDateFormatted,
      drawTime: drawTime ?? this.drawTime,
      drawTimeFormatted: drawTimeFormatted ?? this.drawTimeFormatted,
      drawTimeSimple: drawTimeSimple ?? this.drawTimeSimple,
      isOpen: isOpen ?? this.isOpen,
      isActive: isActive ?? this.isActive,
    );
  }
  
  @override
  String toString() {
    return 'Draw(id: $id, drawDate: $drawDate, drawDateFormatted: $drawDateFormatted, drawTime: $drawTime, drawTimeFormatted: $drawTimeFormatted, drawTimeSimple: $drawTimeSimple, isOpen: $isOpen, isActive: $isActive)';
  }
}
