class CommissionReport {
  final String? date;
  final String? dateFormatted;
  final num? commissionRate;
  final String? commissionRateFormatted;
  final num? totalSales;
  final String? totalSalesFormatted;
  final num? commissionAmount;
  final String? commissionAmountFormatted;

  CommissionReport({
    this.date,
    this.dateFormatted,
    this.commissionRate,
    this.commissionRateFormatted,
    this.totalSales,
    this.totalSalesFormatted,
    this.commissionAmount,
    this.commissionAmountFormatted,
  });

  factory CommissionReport.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }
    return CommissionReport(
      date: json['date'] as String?,
      dateFormatted: json['date_formatted'] as String?,
      commissionRate: parseNum(json['commission_rate']),
      commissionRateFormatted: json['commission_rate_formatted'] as String?,
      totalSales: parseNum(json['total_sales']),
      totalSalesFormatted: json['total_sales_formatted'] as String?,
      commissionAmount: parseNum(json['commission_amount']),
      commissionAmountFormatted: json['commission_amount_formatted'] as String?,
    );
  }
}
