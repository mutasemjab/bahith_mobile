import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcements/presentation/pages/announcement_detail_page.dart';
import '../../features/announcements/presentation/pages/announcements_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/categories/presentation/pages/category_detail_page.dart';
import '../../features/categories/presentation/pages/subject_detail_page.dart';
import '../../features/conduct/presentation/pages/conduct_page.dart';
import '../../features/course_content/presentation/pages/course_content_page.dart';
import '../../features/course_content/presentation/pages/lesson_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/educational_notes/presentation/pages/educational_notes_page.dart';
import '../../features/exams/presentation/cubit/exam_cubit.dart';
import '../../features/exams/presentation/pages/exam_detail_page.dart';
import '../../features/exams/presentation/pages/exam_take_page.dart';
import '../../features/exams/presentation/pages/exams_page.dart';
import '../../features/files/presentation/pages/files_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/previous_year_exams/presentation/pages/previous_year_exam_detail_page.dart';
import '../../features/previous_year_exams/presentation/pages/previous_year_exams_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/my_courses_page.dart';
import '../../features/profile/presentation/pages/my_exams_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/question_banks/presentation/pages/question_bank_detail_page.dart';
import '../../features/question_banks/presentation/pages/question_banks_page.dart';
import '../../features/teachers/presentation/pages/teacher_detail_page.dart';
import '../../features/teachers/presentation/pages/teachers_page.dart';
import '../../features/worksheets/presentation/pages/worksheet_detail_page.dart';
import '../../features/worksheets/presentation/pages/worksheets_page.dart';
import '../di/service_locator.dart';
import 'app_shell.dart';
import 'go_router_refresh_stream.dart';

import '../services/app_settings_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter() {
  final authCubit = sl<AuthCubit>();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isConductRoute = location == '/conduct';

      if (authState is AuthConductRequired) {
        return isConductRoute ? null : '/conduct';
      }

      if (authState is AuthAuthenticated &&
          (isAuthRoute || isConductRoute || location == '/')) {
        return '/home';
      }
      if (authState is AuthUnauthenticated && !isAuthRoute && location != '/') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/conduct',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const ConductPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) {
                  final showCommerce = AppSettingsScope.of(
                    context,
                  ).showCommerce;
                  if (!showCommerce) {
                    return const MyCoursesPage();
                  }
                  return CoursesPage(
                    categoryId: _intParam(state, 'category_id'),
                    subjectId: _intParam(state, 'subject_id'),
                    teacherId: _intParam(state, 'teacher_id'),
                    featured: state.uri.queryParameters['featured'] == '1',
                    trending: state.uri.queryParameters['trending'] == '1',
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exams',
                builder: (context, _) {
                  final showCommerce = AppSettingsScope.of(
                    context,
                  ).showCommerce;
                  if (!showCommerce) {
                    return const MyExamsPage();
                  }
                  return const ExamsPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/announcements',
                builder: (_, _) => const AnnouncementsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/categories/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => CategoryDetailPage(
          categoryId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/subjects/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => SubjectDetailPage(
          subjectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/courses/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            CourseDetailPage(courseId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/courses/:id/content',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            CourseContentPage(courseId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/lessons/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => LessonPage(
          lessonId: int.parse(state.pathParameters['id']!),
          resumeSeconds: _intParam(state, 'resume'),
        ),
      ),
      GoRoute(
        path: '/teachers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const TeachersPage(),
      ),
      GoRoute(
        path: '/teachers/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => TeacherDetailPage(
          teacherId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/exams/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            ExamDetailPage(examId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/exams/:id/take',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ExamTakePage(cubit: state.extra as ExamCubit),
      ),
      GoRoute(
        path: '/previous-year-exams',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const PreviousYearExamsPage(),
      ),
      GoRoute(
        path: '/previous-year-exams/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PreviousYearExamDetailPage(
          examId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/question-banks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const QuestionBanksPage(),
      ),
      GoRoute(
        path: '/question-banks/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => QuestionBankDetailPage(
          bankId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/worksheets',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const WorksheetsPage(),
      ),
      GoRoute(
        path: '/worksheets/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => WorksheetDetailPage(
          worksheetId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/files',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const FilesPage(),
      ),
      GoRoute(
        path: '/educational-notes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const EducationalNotesPage(),
      ),
      GoRoute(
        path: '/announcements/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => AnnouncementDetailPage(
          announcementId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/my-courses',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const MyCoursesPage(),
      ),
      GoRoute(
        path: '/my-exams',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const MyExamsPage(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const EditProfilePage(),
      ),
    ],
  );
}

int? _intParam(GoRouterState state, String key) {
  final value = state.uri.queryParameters[key];
  return value == null ? null : int.tryParse(value);
}
