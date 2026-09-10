import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../banners/presentation/widgets/banner_slider.dart';
import '../../../categories/presentation/widgets/category_circle.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../../notifications/presentation/cubit/unread_notifications_cubit.dart';
import '../../../teachers/presentation/widgets/teacher_card.dart';
import '../../../weekly_planner/domain/entities/weekly_planner_entity.dart';
import '../../../weekly_planner/presentation/cubit/weekly_planner_cubit.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/sibling_switch_sheet.dart';
import '../widgets/weekly_planner_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit = sl<HomeCubit>()..load();
  late final WeeklyPlannerCubit _plannerCubit = sl<WeeklyPlannerCubit>()
    ..load();
  int? _lastStudentId;

  @override
  void dispose() {
    _cubit.close();
    _plannerCubit.close();
    super.dispose();
  }

  /// After a sibling switch, [AuthCubit] emits a new authenticated student
  /// with a different id — reload home data so it reflects that student's
  /// class/content instead of the previous one.
  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state is! AuthAuthenticated) return;
    if (_lastStudentId != null && _lastStudentId != state.student.id) {
      _cubit.load();
      _plannerCubit.load();
    }
    _lastStudentId = state.student.id;
  }

  @override
  Widget build(BuildContext context) {
    final showCommerce = AppSettingsScope.of(context).showCommerce;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocListener<AuthCubit, AuthState>(
          listener: _onAuthChanged,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _cubit.load,
            child: BlocBuilder<HomeCubit, HomeState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is HomeError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: _cubit.load,
                  );
                }

                final loading = state is HomeLoading;
                final home = state is HomeLoaded ? state.home : null;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _Header(),
                    const SizedBox(height: 18),
                    _SearchBar(),
                    const SizedBox(height: 18),
                    const BannerSlider(),
                    const SizedBox(height: 18),
                    BlocBuilder<
                      WeeklyPlannerCubit,
                      ResourceState<WeeklyPlannerEntity?>
                    >(
                      bloc: _plannerCubit,
                      builder: (context, plannerState) =>
                          WeeklyPlannerCard(state: plannerState),
                    ),
                    const SizedBox(height: 22),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ShimmerBox(height: 84, radius: AppRadius.sm),
                      )
                    else
                      SectionHeader(
                        title: 'الأقسام',
                        actionLabel: 'عرض الكل',
                        onAction: () => context.push('/categories'),
                      ),
                    const SizedBox(height: 14),
                    if (loading)
                      const ShimmerCardList(itemWidth: 82, itemHeight: 112)
                    else if (home!.categories.isEmpty)
                      const SizedBox.shrink()
                    else
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: home.categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (_, i) => CategoryCircle(
                            category: home.categories[i],
                            index: i,
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    const _ScheduleQuickLinks(),
                    if (showCommerce) ...[
                      const SizedBox(height: 26),
                      SectionHeader(
                        title: 'دورات مميزة',
                        actionLabel: 'عرض الكل',
                        onAction: () => context.push('/courses?featured=1'),
                      ),
                      const SizedBox(height: 14),
                      if (loading)
                        const ShimmerCardList()
                      else if (home!.featuredCourses.isEmpty)
                        const SizedBox.shrink()
                      else
                        SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: home.featuredCourses.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) =>
                                CourseCard(course: home.featuredCourses[i]),
                          ),
                        ),
                      const SizedBox(height: 26),
                      SectionHeader(
                        title: 'الأكثر رواجاً',
                        actionLabel: 'عرض الكل',
                        onAction: () => context.push('/courses?trending=1'),
                      ),
                      const SizedBox(height: 14),
                      if (loading)
                        const ShimmerCardList()
                      else if (home!.trendingCourses.isEmpty)
                        const SizedBox.shrink()
                      else
                        SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: home.trendingCourses.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) =>
                                CourseCard(course: home.trendingCourses[i]),
                          ),
                        ),
                    ],
                    const SizedBox(height: 26),
                    SectionHeader(
                      title: 'أفضل المعلمين',
                      actionLabel: 'عرض الكل',
                      onAction: () => context.push('/teachers'),
                    ),
                    const SizedBox(height: 14),
                    if (loading)
                      const ShimmerCardList(itemWidth: 140, itemHeight: 170)
                    else if (home!.topTeachers.isEmpty)
                      const SizedBox.shrink()
                    else
                      SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: home.topTeachers.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              TeacherCard(teacher: home.topTeachers[i]),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final student = state is AuthAuthenticated ? state.student : null;
          final hasSiblings = student != null && student.siblings.isNotEmpty;
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: hasSiblings
                      ? () => showSiblingSwitchSheet(context, student)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أهلاً بك 👋',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              student?.name ?? 'طالب الباحث',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          if (hasSiblings) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.expand_more_rounded,
                              size: 20,
                              color: AppColors.navy,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<UnreadNotificationsCubit, int>(
                bloc: sl<UnreadNotificationsCubit>(),
                builder: (context, unreadCount) => GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: AppNetworkImage(
                      url: student?.avatar,
                      width: 46,
                      height: 46,
                      radius: 999,
                      fallbackIcon: Icons.person_rounded,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleQuickLinks extends StatelessWidget {
  const _ScheduleQuickLinks();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleCard(
              icon: Icons.calendar_month_rounded,
              label: 'جدول الحصص',
              onTap: () => context.push('/class-schedule'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ScheduleCard(
              icon: Icons.event_available_rounded,
              label: 'جدول الامتحانات',
              onTap: () => context.push('/exam-schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/courses'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
              SizedBox(width: 10),
              Text(
                'ابحث عن دورة، معلم، أو مادة...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
