import 'package:flutter/material.dart';
import 'package:bettingapp/utils/app_colors.dart';

class StatsTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<String> rowLabels;
  final bool showTotal;
  final Color headerColor;
  final List<int> boldColumns;
  final List<int> highlightColumns;

  const StatsTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowLabels,
    this.showTotal = true,
    this.headerColor = AppColors.primaryBlue,
    this.boldColumns = const [],
    this.highlightColumns = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildCell(
                  '',
                  flex: 2,
                  isHeader: true,
                  color: headerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                  ),
                ),
                ...columns.asMap().entries.map((entry) {
                  final isLast = entry.key == columns.length - 1;
                  final isBold = boldColumns.contains(entry.key);
                  return _buildCell(
                    entry.value,
                    isHeader: true,
                    color: headerColor,
                    extraBold: isBold,
                    borderRadius: isLast
                        ? const BorderRadius.only(
                            topRight: Radius.circular(8),
                          )
                        : null,
                  );
                }),
              ],
            ),
          ),

          // Data rows
          ...rows.asMap().entries.map((rowEntry) {
            final rowIndex = rowEntry.key;
            final rowData = rowEntry.value;
            final isLastRow = rowIndex == rows.length - 1;
            
            return Container(
              decoration: BoxDecoration(
                color: rowIndex.isEven ? Colors.grey.shade50 : Colors.white,
                borderRadius: isLastRow && !showTotal
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  _buildCell(
                    rowLabels[rowIndex],
                    flex: 2,
                    isHeader: false,
                    isLabel: true,
                    borderRadius: isLastRow && !showTotal
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          )
                        : null,
                  ),
                  ...rowData.asMap().entries.map((cellEntry) {
                    final isLastColumn = cellEntry.key == rowData.length - 1;
                    final isHighlighted = highlightColumns.contains(cellEntry.key);
                    return _buildCell(
                      cellEntry.value,
                      isHeader: false,
                      extraBold: isHighlighted,
                      borderRadius: isLastRow && !showTotal && isLastColumn
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            )
                          : null,
                    );
                  }),
                ],
              ),
            );
          }),

          // Total row (optional)
          if (showTotal)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  _buildCell(
                    'TOTAL',
                    flex: 2,
                    isHeader: true,
                    color: const Color(0xFFF5F5F5),
                    textColor: AppColors.primaryText,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  ...List.generate(columns.length, (colIndex) {
                    // Calculate column totals
                    num total = 0;
                    for (var row in rows) {
                      // Remove currency symbol and commas before parsing
                      final valueStr = row[colIndex].replaceAll(RegExp(r'[^\d.]'), '');
                      if (valueStr.isNotEmpty) {
                        total += num.tryParse(valueStr) ?? 0;
                      }
                    }
                    
                    final isLastColumn = colIndex == columns.length - 1;
                    return _buildCell(
                      'PHP ${total.toStringAsFixed(0)}',
                      isHeader: true,
                      color: const Color(0xFFF5F5F5),
                      textColor: AppColors.primaryText,
                      borderRadius: isLastColumn
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            )
                          : null,
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(
    String text, {
    int flex = 1,
    bool isHeader = false,
    bool isLabel = false,
    bool extraBold = false,
    Color? color,
    Color? textColor,
    BorderRadius? borderRadius,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: isLabel ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              color: textColor ??
                  (isHeader ? Colors.white : AppColors.primaryText),
              fontWeight: extraBold ? FontWeight.w900 : (isHeader || isLabel ? FontWeight.bold : FontWeight.normal),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
