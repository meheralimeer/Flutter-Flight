import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const CustomBadge({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? kPrimaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? kPrimaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
