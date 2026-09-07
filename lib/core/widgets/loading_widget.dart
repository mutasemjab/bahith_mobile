import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  const LoadingWidget({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class LoadingMoreWidget extends StatelessWidget {
  const LoadingMoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: LoadingWidget(size: 22),
    );
  }
}
