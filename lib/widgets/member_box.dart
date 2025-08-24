import 'package:flutter/material.dart';

class MemberBox extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final Color textColor;        // Text color
  final Color backgroundColor;  // Background color

  const MemberBox({
    super.key,
    required this.name,
    this.width = 120,
    this.height = 60,
    this.textColor = Colors.yellowAccent,       // Default text color
    this.backgroundColor = Colors.black87,      // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellowAccent, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
