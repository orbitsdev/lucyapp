class Schedule {
  final int? id;
  final String? name;
  final String? drawTime;
  final String? drawTimeFormatted;
  
  Schedule({
    this.id,
    this.name,
    this.drawTime,
    this.drawTimeFormatted,
  });
  
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      name: json['name'],
      drawTime: json['draw_time'],
      drawTimeFormatted: json['draw_time_formatted'],
    );
  }
  
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      name: map['name'],
      drawTime: map['draw_time'],
      drawTimeFormatted: map['draw_time_formatted'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'draw_time': drawTime,
      'draw_time_formatted': drawTimeFormatted,
    };
  }
  
  Schedule copyWith({
    int? id,
    String? name,
    String? drawTime,
    String? drawTimeFormatted,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      drawTime: drawTime ?? this.drawTime,
      drawTimeFormatted: drawTimeFormatted ?? this.drawTimeFormatted,
    );
  }
  
  @override
  String toString() {
    return 'Schedule(id: $id, name: $name, drawTime: $drawTime, drawTimeFormatted: $drawTimeFormatted)';
  }
}
