class SalesReportTotals {
  final double? sales;
  final double? hits;
  final double? gross;
  final int? voided;
  
  SalesReportTotals({
    this.sales,
    this.hits,
    this.gross,
    this.voided,
  });
  
  factory SalesReportTotals.fromJson(Map<String, dynamic> json) {
    return SalesReportTotals(
      sales: json['sales'] is int ? (json['sales'] as int).toDouble() : json['sales'],
      hits: json['hits'] is int ? (json['hits'] as int).toDouble() : json['hits'],
      gross: json['gross'] is int ? (json['gross'] as int).toDouble() : json['gross'],
      voided: json['voided'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'sales': sales,
      'hits': hits,
      'gross': gross,
      'voided': voided,
    };
  }
}

class SalesReportDraw {
  final int? drawId;
  final String? time;
  final String? timeFormatted;
  final String? type;
  final String? winningNumber;
  final double? sales;
  final String? salesFormatted;
  final double? hits;
  final String? hitsFormatted;
  final double? gross;
  final String? grossFormatted;
  final int? voided;
  final String? voidedFormatted;
  
  SalesReportDraw({
    this.drawId,
    this.time,
    this.timeFormatted,
    this.type,
    this.winningNumber,
    this.sales,
    this.salesFormatted,
    this.hits,
    this.hitsFormatted,
    this.gross,
    this.grossFormatted,
    this.voided,
    this.voidedFormatted,
  });
  
  factory SalesReportDraw.fromJson(Map<String, dynamic> json) {
    return SalesReportDraw(
      drawId: json['draw_id'],
      time: json['time'],
      timeFormatted: json['time_formatted'],
      type: json['type'],
      winningNumber: json['winning_number'],
      sales: json['sales'] is int ? (json['sales'] as int).toDouble() : json['sales'],
      salesFormatted: json['sales_formatted'],
      hits: json['hits'] is int ? (json['hits'] as int).toDouble() : json['hits'],
      hitsFormatted: json['hits_formatted'],
      gross: json['gross'] is int ? (json['gross'] as int).toDouble() : json['gross'],
      grossFormatted: json['gross_formatted'],
      voided: json['voided'],
      voidedFormatted: json['voided_formatted'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'draw_id': drawId,
      'time': time,
      'time_formatted': timeFormatted,
      'type': type,
      'winning_number': winningNumber,
      'sales': sales,
      'sales_formatted': salesFormatted,
      'hits': hits,
      'hits_formatted': hitsFormatted,
      'gross': gross,
      'gross_formatted': grossFormatted,
      'voided': voided,
      'voided_formatted': voidedFormatted,
    };
  }
}

class SalesReport {
  final String? date;
  final String? dateFormatted;
  final SalesReportTotals? totals;
  final List<SalesReportDraw>? draws;
  
  SalesReport({
    this.date,
    this.dateFormatted,
    this.totals,
    this.draws,
  });
  
  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      date: json['date'],
      dateFormatted: json['date_formatted'],
      totals: json['totals'] != null ? SalesReportTotals.fromJson(json['totals']) : null,
      draws: json['draws'] != null
          ? (json['draws'] as List).map((item) => SalesReportDraw.fromJson(item)).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'date_formatted': dateFormatted,
      'totals': totals?.toMap(),
      'draws': draws?.map((item) => item.toMap()).toList(),
    };
  }
}
