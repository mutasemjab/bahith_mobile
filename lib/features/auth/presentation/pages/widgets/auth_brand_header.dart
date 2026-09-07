import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Shared branded header shown atop login/register — logo mark, title
/// and subtitle in the academy's primary gradient.
class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(width: 88, height: 88, child: Image.asset('assets/icon.png')),
        const Text(
          'أكاديمية ومدارس الباحث',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
