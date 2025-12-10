import 'package:flutter/material.dart';
import 'package:manager_web/theme/app_theme.dart';

/// iOS Style Grouped Card
/// Used for creating grouped list sections like iOS Settings
class IOSGroupedCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;

  const IOSGroupedCard({
    super.key,
    required this.children,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusMedium,
        ),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    if (children.isEmpty) return [];
    
    final List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      widgets.add(
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: children[i],
        ),
      );
      
      // Add separator between items (except last)
      if (i < children.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppTheme.separator,
            indent: AppTheme.spacing16,
            endIndent: AppTheme.spacing16,
          ),
        );
      }
    }
    
    return widgets;
  }
}

/// iOS Style Inset Grouped Card
/// Used for creating inset grouped sections (like iOS Settings with margins)
class IOSInsetGroupedCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const IOSInsetGroupedCard({
    super.key,
    required this.children,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    if (children.isEmpty) return [];
    
    final List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      widgets.add(
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: children[i],
        ),
      );
      
      // Add separator between items (except last)
      if (i < children.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            thickness: 0.5,
            color: AppTheme.separator,
            indent: AppTheme.spacing16,
            endIndent: AppTheme.spacing16,
          ),
        );
      }
    }
    
    return widgets;
  }
}

/// iOS Style List Row
/// Used inside grouped cards for list items
class IOSListRow extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const IOSListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppTheme.spacing12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: AppTheme.body.copyWith(
                  color: AppTheme.label,
                ),
                child: title,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacing4),
                DefaultTextStyle(
                  style: AppTheme.footnote.copyWith(
                    color: AppTheme.secondaryLabel,
                  ),
                  child: subtitle!,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppTheme.spacing8),
          DefaultTextStyle(
            style: AppTheme.body.copyWith(
              color: AppTheme.tertiaryLabel,
            ),
            child: trailing!,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Container(
          color: backgroundColor ?? Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: content,
        ),
      );
    }

    return Container(
      color: backgroundColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      child: content,
    );
  }
}

