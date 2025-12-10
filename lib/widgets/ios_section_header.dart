import 'package:flutter/material.dart';
import 'package:manager_web/theme/app_theme.dart';

/// iOS Style Section Header
/// Used for section titles in grouped lists
class IOSSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const IOSSectionHeader({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(
        AppTheme.spacing16,
        AppTheme.spacing24,
        AppTheme.spacing16,
        AppTheme.spacing8,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.footnote.copyWith(
          color: AppTheme.secondaryLabel,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

