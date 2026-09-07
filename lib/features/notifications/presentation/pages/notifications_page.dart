import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/unread_notifications_cubit.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsCubit _cubit = sl<NotificationsCubit>()
    ..loadFirstPage();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _markAllRead() async {
    await sl<UnreadNotificationsCubit>().markAllRead();
    if (mounted) _cubit.loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('قراءة الكل')),
        ],
      ),
      body: PaginatedListView<NotificationEntity>(
        cubit: _cubit,
        emptyMessage: 'لا توجد إشعارات حالياً',
        emptyIcon: Icons.notifications_none_rounded,
        itemBuilder: (_, notification) =>
            _NotificationTile(notification: notification),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.card
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: notification.isRead ? AppColors.border : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: notification.isRead
                        ? FontWeight.w600
                        : FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                if (notification.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    notification.createdAt!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
