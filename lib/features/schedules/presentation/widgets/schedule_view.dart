import 'package:flutter/material.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/schedule_entity.dart';

/// Shared body for the class-schedule and exam-schedule screens — both are
/// a single admin-uploaded image (or an empty state when none exists yet).
class ScheduleView extends StatelessWidget {
  final ResourceState<ScheduleEntity?> state;
  final VoidCallback onRetry;
  final String emptyMessage;

  const ScheduleView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ResourceLoading<ScheduleEntity?>) return const LoadingWidget();
    if (state is ResourceError<ScheduleEntity?>) {
      final error = state as ResourceError<ScheduleEntity?>;
      return AppErrorView(message: error.message, onRetry: onRetry);
    }

    final schedule = (state as ResourceLoaded<ScheduleEntity?>).data;
    if (schedule == null) {
      return EmptyState(
        message: emptyMessage,
        icon: Icons.calendar_month_rounded,
      );
    }

    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: Center(
        child: AppNetworkImage(
          url: schedule.imageUrl,
          width: double.infinity,
          height: double.infinity,
          radius: 0,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
