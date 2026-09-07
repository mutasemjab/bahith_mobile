import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit = sl<HomeCubit>()..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCommerce = AppSettingsScope.of(context).showCommerce;
    return Scaffold(
      body: SafeArea(
        bottom: false,
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
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
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
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
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
          return Row(
            children: [
              Expanded(
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
                    Text(
                      student?.name ?? 'طالب الباحث',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
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
