import 'package:flutter/material.dart';
import 'package:bettingapp/utils/app_colors.dart';


// Coordinator version: receives data from summary screen, no controller logic.
Widget _headerCell(String label, {required double width}) => Container(
  width: width,
  padding: const EdgeInsets.symmetric(vertical: 10),
  alignment: Alignment.center,
  child: Text(
    label,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  ),
);

Widget _dataCell({required Widget child, required double width}) => Container(
  width: width,
  alignment: Alignment.center,
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: child,
);

class TallySheetScreen extends StatelessWidget {
  final String tellerName;
  final Map<String, dynamic> summaryData;
  final List<Map<String, dynamic>> drawData;

  const TallySheetScreen({
    Key? key,
    required this.tellerName,
    required this.summaryData,
    required this.drawData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('$tellerName Tally Sheet'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: Column(
        children: [
          // Summary Section
          Container(
            width: double.infinity,
            color: AppColors.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Summary Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        'GROSS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'SALES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'HITS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'VOIDED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                // Summary Values
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          summaryData['gross'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          summaryData['sales'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          summaryData['hits'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          summaryData['voided'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Draw Section Header & Table (Uniform Style)
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          _headerCell('DRAW', width: 100),
                          _headerCell('GROSS', width: 90),
                          _headerCell('SALES', width: 90),
                          _headerCell('HITS', width: 90),
                        ],
                      ),
                    ),
                    // Table Rows
                    ...drawData.map((item) => Row(
                          children: [
                            _dataCell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  item['draw'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              width: 100,
                            ),
                            _dataCell(
                              child: Text(
                                item['gross'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              width: 90,
                            ),
                            _dataCell(
                              child: Text(
                                item['sales'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item['sales'] == '0' ? Colors.grey : Colors.red,
                                  fontWeight: item['sales'] == '0' ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              width: 90,
                            ),
                            _dataCell(
                              child: Text(
                                item['hits'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              width: 90,
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
