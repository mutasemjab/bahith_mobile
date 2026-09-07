import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../domain/entities/announcement_entity.dart';
import '../cubit/announcements_cubit.dart';
import '../widgets/announcement_card.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late final AnnouncementsCubit _cubit = sl<AnnouncementsCubit>()
    ..loadFirstPage();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعلانات')),
      body: PaginatedListView<AnnouncementEntity>(
        cubit: _cubit,
        emptyMessage: 'لا توجد إعلانات حالياً',
        emptyIcon: Icons.campaign_rounded,
        itemBuilder: (_, announcement) =>
            AnnouncementCard(announcement: announcement),
      ),
    );
  }
}
