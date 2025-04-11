import 'package:flutter/material.dart';

class ToggleSwitch extends StatelessWidget {
  final bool isFirstTab;
  final VoidCallback onToggle;
  final String firstTabName;
  final String secondTabName;
  final double selectionWidth;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle? textStyle;

  const ToggleSwitch({
    super.key,
    required this.isFirstTab,
    required this.onToggle,
    required this.firstTabName,
    required this.secondTabName,
    this.selectionWidth = 50,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 105,
        height: 40,
        decoration: BoxDecoration(
          color: unselectedColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: isFirstTab ? 0 : selectionWidth,
              right: isFirstTab ? selectionWidth : 0,
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel(firstTabName, isFirstTab),
                _buildLabel(secondTabName, !isFirstTab),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isSelected) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14),
        ),
      ),
    );
  }
}
