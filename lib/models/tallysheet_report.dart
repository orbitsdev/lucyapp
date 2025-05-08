class TallysheetDrawData {
  final int? drawId;
  final String? type;
  final String? winningNumber;
  final String? drawLabel;
  final String? drawTime;
  final String? drawTimeFormatted;
  final double? gross;
  final String? grossFormatted;
  final double? sales;
  final String? salesFormatted;
  final double? hits;
  final String? hitsFormatted;
  final double? kabig;
  final String? kabigFormatted;
  
  TallysheetDrawData({
    this.drawId,
    this.type,
    this.winningNumber,
    this.drawLabel,
    this.drawTime,
    this.drawTimeFormatted,
    this.gross,
    this.grossFormatted,
    this.sales,
    this.salesFormatted,
    this.hits,
    this.hitsFormatted,
    this.kabig,
    this.kabigFormatted,
  });
  
  factory TallysheetDrawData.fromJson(Map<String, dynamic> json) {
    return TallysheetDrawData(
      drawId: json['draw_id'],
      type: json['type'],
      winningNumber: json['winning_number'],
      drawLabel: json['draw_label'],
      drawTime: json['draw_time'],
      drawTimeFormatted: json['draw_time_formatted'],
      gross: json['gross'] is int ? (json['gross'] as int).toDouble() : json['gross'],
      grossFormatted: json['gross_formatted'],
      sales: json['sales'] is int ? (json['sales'] as int).toDouble() : json['sales'],
      salesFormatted: json['sales_formatted'],
      hits: json['hits'] is int ? (json['hits'] as int).toDouble() : json['hits'],
      hitsFormatted: json['hits_formatted'],
      kabig: json['kabig'] is int ? (json['kabig'] as int).toDouble() : json['kabig'],
      kabigFormatted: json['kabig_formatted'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'draw_id': drawId,
      'type': type,
      'winning_number': winningNumber,
      'draw_label': drawLabel,
      'draw_time': drawTime,
      'draw_time_formatted': drawTimeFormatted,
      'gross': gross,
      'gross_formatted': grossFormatted,
      'sales': sales,
      'sales_formatted': salesFormatted,
      'hits': hits,
      'hits_formatted': hitsFormatted,
      'kabig': kabig,
      'kabig_formatted': kabigFormatted,
    };
  }
}

class TallysheetReport {
  final String? date;
  final String? dateFormatted;
  final double? gross;
  final String? grossFormatted;
  final double? sales;
  final String? salesFormatted;
  final double? hits;
  final String? hitsFormatted;
  final double? kabig;
  final String? kabigFormatted;
  final double? voided;
  final String? voidedFormatted;
  final List<TallysheetDrawData>? perDraw;
  
  TallysheetReport({
    this.date,
    this.dateFormatted,
    this.gross,
    this.grossFormatted,
    this.sales,
    this.salesFormatted,
    this.hits,
    this.hitsFormatted,
    this.kabig,
    this.kabigFormatted,
    this.voided,
    this.voidedFormatted,
    this.perDraw,
  });
  
  factory TallysheetReport.fromJson(Map<String, dynamic> json) {
    return TallysheetReport(
      date: json['date'],
      dateFormatted: json['date_formatted'],
      gross: json['gross'] is int ? (json['gross'] as int).toDouble() : json['gross'],
      grossFormatted: json['gross_formatted'],
      sales: json['sales'] is int ? (json['sales'] as int).toDouble() : json['sales'],
      salesFormatted: json['sales_formatted'],
      hits: json['hits'] is int ? (json['hits'] as int).toDouble() : json['hits'],
      hitsFormatted: json['hits_formatted'],
      kabig: json['kabig'] is int ? (json['kabig'] as int).toDouble() : json['kabig'],
      kabigFormatted: json['kabig_formatted'],
      voided: json['voided'] is int ? (json['voided'] as int).toDouble() : json['voided'],
      voidedFormatted: json['voided_formatted'],
      perDraw: json['per_draw'] != null
          ? (json['per_draw'] as List).map((item) => TallysheetDrawData.fromJson(item)).toList()
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'date_formatted': dateFormatted,
      'gross': gross,
      'gross_formatted': grossFormatted,
      'sales': sales,
      'sales_formatted': salesFormatted,
      'hits': hits,
      'hits_formatted': hitsFormatted,
      'kabig': kabig,
      'kabig_formatted': kabigFormatted,
      'voided': voided,
      'voided_formatted': voidedFormatted,
      'per_draw': perDraw?.map((item) => item.toMap()).toList(),
    };
  }
}
