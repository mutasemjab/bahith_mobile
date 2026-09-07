import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/announcement_entity.dart';
import '../cubit/announcement_detail_cubit.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final int announcementId;
  const AnnouncementDetailPage({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnnouncementDetailCubit>()..load(announcementId),
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعلان')),
        body:
            BlocBuilder<
              AnnouncementDetailCubit,
              ResourceState<AnnouncementEntity>
            >(
              builder: (context, state) {
                if (state is ResourceLoading) return const LoadingWidget();
                if (state is ResourceError<AnnouncementEntity>) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<AnnouncementDetailCubit>().load(
                      announcementId,
                    ),
                  );
                }
                final announcement =
                    (state as ResourceLoaded<AnnouncementEntity>).data;
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (announcement.image != null)
                      GestureDetector(
                        onTap: () =>
                            showFullscreenImage(context, announcement.image!),
                        child: AppNetworkImage(
                          url: announcement.image,
                          height: 220,
                          width: double.infinity,
                          radius: 0,
                          fallbackIcon: Icons.campaign_rounded,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (announcement.publishedAt != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  announcement.publishedAt!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 18),
                          Text(
                            announcement.body,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}
