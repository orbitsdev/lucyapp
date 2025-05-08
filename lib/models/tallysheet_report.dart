class TallysheetDrawData {
  final int? drawId;
  final String? type;
  final String? winningNumber;
  final String? drawLabel;
  final double? gross;
  final double? sales;
  final double? hits;
  final double? kabig;
  
  TallysheetDrawData({
    this.drawId,
    this.type,
    this.winningNumber,
    this.drawLabel,
    this.gross,
    this.sales,
    this.hits,
    this.kabig,
  });
  
  factory TallysheetDrawData.fromJson(Map<String, dynamic> json) {
    return TallysheetDrawData(
      drawId: json['draw_id'],
      type: json['type'],
      winningNumber: json['winning_number'],
      drawLabel: json['draw_label'],
      gross: json['gross'] is int ? (json['gross'] as int).toDouble() : json['gross'],
      sales: json['sales'] is int ? (json['sales'] as int).toDouble() : json['sales'],
      hits: json['hits'] is int ? (json['hits'] as int).toDouble() : json['hits'],
      kabig: json['kabig'] is int ? (json['kabig'] as int).toDouble() : json['kabig'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'draw_id': drawId,
      'type': type,
      'winning_number': winningNumber,
      'draw_label': drawLabel,
      'gross': gross,
      'sales': sales,
      'hits': hits,
      'kabig': kabig,
    };
  }
}

class TallysheetReport {
  final String? date;
  final double? gross;
  final double? sales;
  final double? hits;
  final double? kabig;
  final double? voided;
  final List<TallysheetDrawData>? perDraw;
  
  TallysheetReport({
    this.date,
    this.gross,
    this.sales,
    this.hits,
    this.kabig,
    this.voided,
    this.perDraw,
  });
  
  factory TallysheetReport.fromJson(Map<String, dynamic> json) {
    return TallysheetReport(
      date: json['date'],
      gross: json['gross'] is int ? (json['gross'] as int).toDouble() : json['gross'],
      sales: json['sales'] is int ? (json['sales'] as int).toDouble() : json['sales'],
      hits: json['hits'] is int ? (json['hits'] as int).toDouble() : json['hits'],
      kabig: json['kabig'] is int ? (json['kabig'] as int).toDouble() : json['kabig'],
      voided: json['voided'] is int ? (json['voided'] as int).toDouble() : json['voided'],
      perDraw: json['per_draw'] != null
          ? (json['per_draw'] as List).map((item) => TallysheetDrawData.fromJson(item)).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'gross': gross,
      'sales': sales,
      'hits': hits,
      'kabig': kabig,
      'voided': voided,
      'per_draw': perDraw?.map((item) => item.toMap()).toList(),
    };
  }
}
