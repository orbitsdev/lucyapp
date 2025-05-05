import 'package:flutter/material.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LocationDropdown extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  final List<String> locations;
  final String label;

  const LocationDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.locations = const ['Davao', 'Isulan', 'Tacurong', 'S2', 'S3', 'L2', 'L3', '4D', 'P3'],
    this.label = 'SELECT LOCATION',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: locations.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          hint: Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }
}
