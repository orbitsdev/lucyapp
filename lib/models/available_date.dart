class AvailableDate {
  final int? id;
  final String? date;
  final String? dateFormatted;
  
  AvailableDate({
    this.id,
    this.date,
    this.dateFormatted,
  });
  
  factory AvailableDate.fromJson(Map<String, dynamic> json) {
    return AvailableDate(
      id: json['id'],
      date: json['date'],
      dateFormatted: json['date_formatted'],
    );
  }
  
  factory AvailableDate.fromMap(Map<String, dynamic> map) {
    return AvailableDate(
      id: map['id'],
      date: map['date'],
      dateFormatted: map['date_formatted'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'date_formatted': dateFormatted,
    };
  }
  
  AvailableDate copyWith({
    int? id,
    String? date,
    String? dateFormatted,
  }) {
    return AvailableDate(
      id: id ?? this.id,
      date: date ?? this.date,
      dateFormatted: dateFormatted ?? this.dateFormatted,
    );
  }
  
  @override
  String toString() {
    return 'AvailableDate(id: $id, date: $date, dateFormatted: $dateFormatted)';
  }
}
