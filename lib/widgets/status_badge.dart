import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11.5,
  });

  Color _getBadgeColor() {
    switch (status.toLowerCase()) {
      case 'available':
      case 'present':
      case 'approved':
      case 'resolved':
      case 'fully paid':
        return AppTheme.statusSuccess;

      case 'partially occupied':
      case 'in progress':
      case 'partially paid':
      case 'pending':
      case 'medium':
        return AppTheme.statusWarning;

      case 'full':
      case 'absent':
      case 'rejected':
      case 'high':
      case 'emergency':
        return AppTheme.statusDanger;

      case 'on leave':
      case 'low':
      case 'normal':
      default:
        return AppTheme.statusInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
