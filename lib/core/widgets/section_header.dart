import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            margin: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Row(
                children: [
                  Text(actionLabel!, style: const TextStyle(fontSize: 13)),
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 13),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
