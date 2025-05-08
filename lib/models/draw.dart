class Draw {
  final int? id;
  final String? drawDate;
  final String? drawDateFormatted;
  final String? drawTime;
  final String? drawTimeFormatted;
  final bool? isOpen;
  final bool? isActive;
  
  Draw({
    this.id,
    this.drawDate,
    this.drawDateFormatted,
    this.drawTime,
    this.drawTimeFormatted,
    this.isOpen,
    this.isActive,
  });
  
  factory Draw.fromJson(Map<String, dynamic> json) {
    return Draw(
      id: json['id'],
      drawDate: json['draw_date'],
      drawDateFormatted: json['draw_date_formatted'],
      drawTime: json['draw_time'],
      drawTimeFormatted: json['draw_time_formatted'],
      isOpen: json['is_open'],
      isActive: json['is_active'],
    );
  }
  
  factory Draw.fromMap(Map<String, dynamic> map) {
    return Draw(
      id: map['id'],
      drawDate: map['draw_date'],
      drawDateFormatted: map['draw_date_formatted'],
      drawTime: map['draw_time'],
      drawTimeFormatted: map['draw_time_formatted'],
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
    bool? isOpen,
    bool? isActive,
  }) {
    return Draw(
      id: id ?? this.id,
      drawDate: drawDate ?? this.drawDate,
      drawDateFormatted: drawDateFormatted ?? this.drawDateFormatted,
      drawTime: drawTime ?? this.drawTime,
      drawTimeFormatted: drawTimeFormatted ?? this.drawTimeFormatted,
      isOpen: isOpen ?? this.isOpen,
      isActive: isActive ?? this.isActive,
    );
  }
  
  @override
  String toString() {
    return 'Draw(id: $id, drawDate: $drawDate, drawDateFormatted: $drawDateFormatted, drawTime: $drawTime, drawTimeFormatted: $drawTimeFormatted, isOpen: $isOpen, isActive: $isActive)';
  }
}
