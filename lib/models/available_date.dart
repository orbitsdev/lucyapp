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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'date_formatted': dateFormatted,
    };
  }
  
  @override
  String toString() {
    return 'AvailableDate(id: $id, date: $date, dateFormatted: $dateFormatted)';
  }
}
