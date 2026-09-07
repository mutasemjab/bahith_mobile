import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/announcements/data/repositories/announcement_repository_impl.dart';
import '../../features/announcements/domain/repositories/announcement_repository.dart';
import '../../features/announcements/presentation/cubit/announcement_detail_cubit.dart';
import '../../features/announcements/presentation/cubit/announcements_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/banners/data/repositories/banner_repository_impl.dart';
import '../../features/banners/domain/repositories/banner_repository.dart';
import '../../features/banners/presentation/cubit/banner_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/presentation/cubit/category_cubit.dart';
import '../../features/conduct/data/repositories/conduct_repository_impl.dart';
import '../../features/conduct/domain/repositories/conduct_repository.dart';
import '../../features/conduct/presentation/cubit/conduct_cubit.dart';
import '../../features/course_content/data/repositories/course_content_repository_impl.dart';
import '../../features/course_content/domain/repositories/course_content_repository.dart';
import '../../features/course_content/presentation/cubit/course_content_cubit.dart';
import '../../features/course_content/presentation/cubit/course_progress_cubit.dart';
import '../../features/course_content/presentation/cubit/lesson_detail_cubit.dart';
import '../../features/courses/data/repositories/course_repository_impl.dart';
import '../../features/courses/domain/repositories/course_repository.dart';
import '../../features/courses/presentation/cubit/course_activation_cubit.dart';
import '../../features/courses/presentation/cubit/course_detail_cubit.dart';
import '../../features/courses/presentation/cubit/courses_cubit.dart';
import '../../features/educational_notes/data/repositories/note_repository_impl.dart';
import '../../features/educational_notes/domain/repositories/note_repository.dart';
import '../../features/educational_notes/presentation/cubit/notes_cubit.dart';
import '../../features/exams/data/repositories/exam_repository_impl.dart';
import '../../features/exams/domain/repositories/exam_repository.dart';
import '../../features/exams/presentation/cubit/exam_cubit.dart';
import '../../features/exams/presentation/cubit/exams_cubit.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/cubit/unread_notifications_cubit.dart';
import '../../features/previous_year_exams/data/repositories/previous_year_exam_repository_impl.dart';
import '../../features/previous_year_exams/domain/repositories/previous_year_exam_repository.dart';
import '../../features/previous_year_exams/presentation/cubit/previous_year_exam_detail_cubit.dart';
import '../../features/previous_year_exams/presentation/cubit/previous_year_exams_cubit.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/my_courses_cubit.dart';
import '../../features/profile/presentation/cubit/my_exams_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/cubit/profile_edit_cubit.dart';
import '../../features/question_banks/data/repositories/question_bank_repository_impl.dart';
import '../../features/question_banks/domain/repositories/question_bank_repository.dart';
import '../../features/question_banks/presentation/cubit/question_bank_detail_cubit.dart';
import '../../features/question_banks/presentation/cubit/question_banks_cubit.dart';
import '../../features/teachers/data/repositories/teacher_repository_impl.dart';
import '../../features/teachers/domain/repositories/teacher_repository.dart';
import '../../features/teachers/presentation/cubit/teacher_detail_cubit.dart';
import '../../features/teachers/presentation/cubit/teachers_cubit.dart';
import '../../features/worksheets/data/repositories/worksheet_repository_impl.dart';
import '../../features/worksheets/domain/repositories/worksheet_repository.dart';
import '../../features/worksheets/presentation/cubit/worksheet_detail_cubit.dart';
import '../../features/worksheets/presentation/cubit/worksheets_cubit.dart';
import '../api/api_client.dart';
import '../services/push_notification_service.dart';
import '../services/app_settings_service.dart';
import '../services/apple_iap_service.dart';
import '../storage/secure_storage.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerSingleton(await SharedPreferences.getInstance());
  sl.registerLazySingleton(() => SecureStorage(sl(), sl()));
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => AppSettingsService(sl()));
  sl.registerLazySingleton(() => AppleIapService(sl()));

  // Student code of conduct — repository is shared by the startup auth gate
  // and the blocking document screen.
  sl.registerLazySingleton<ConductRepository>(
    () => ConductRepositoryImpl(sl(), sl()),
  );
  sl.registerFactory(() => ConductCubit(sl()));

  // Auth — AuthCubit is a singleton: it holds app-wide session state
  // consumed by the home header, profile, and router redirects.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => AuthCubit(sl(), sl(), sl(), sl()));

  // Home
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerFactory(() => HomeCubit(sl()));

  // Banners
  sl.registerLazySingleton<BannerRepository>(() => BannerRepositoryImpl(sl()));
  sl.registerFactory(() => BannerCubit(sl()));

  // Categories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerFactory(() => CategoriesCubit(sl()));
  sl.registerFactory(() => CategoryDetailCubit(sl()));
  sl.registerFactory(() => SubjectDetailCubit(sl()));

  // Courses
  sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryImpl(sl()));
  sl.registerFactoryParam<CoursesCubit, CourseFilters, void>(
    (filters, _) => CoursesCubit(sl(), filters: filters),
  );
  sl.registerFactory(() => CourseDetailCubit(sl()));
  sl.registerFactory(() => CourseActivationCubit(sl()));

  // Course content (units/lessons)
  sl.registerLazySingleton<CourseContentRepository>(
    () => CourseContentRepositoryImpl(sl()),
  );
  sl.registerFactory(() => CourseContentCubit(sl()));
  sl.registerFactory(() => LessonDetailCubit(sl()));
  sl.registerFactory(() => CourseProgressCubit(sl()));

  // Teachers
  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(sl()),
  );
  sl.registerFactory(() => TeachersCubit(sl()));
  sl.registerFactory(() => TeacherDetailCubit(sl()));

  // Exams
  sl.registerLazySingleton<ExamRepository>(() => ExamRepositoryImpl(sl()));
  sl.registerFactory(() => ExamsCubit(sl()));
  sl.registerFactory(() => ExamCubit(sl()));

  // Previous year exams
  sl.registerLazySingleton<PreviousYearExamRepository>(
    () => PreviousYearExamRepositoryImpl(sl()),
  );
  sl.registerFactory(() => PreviousYearExamsCubit(sl()));
  sl.registerFactory(() => PreviousYearExamDetailCubit(sl()));

  // Question banks
  sl.registerLazySingleton<QuestionBankRepository>(
    () => QuestionBankRepositoryImpl(sl()),
  );
  sl.registerFactory(() => QuestionBanksCubit(sl()));
  sl.registerFactory(() => QuestionBankDetailCubit(sl()));

  // Worksheets
  sl.registerLazySingleton<WorksheetRepository>(
    () => WorksheetRepositoryImpl(sl()),
  );
  sl.registerFactory(() => WorksheetsCubit(sl()));
  sl.registerFactory(() => WorksheetDetailCubit(sl()));

  // Educational notes
  sl.registerLazySingleton<NoteRepository>(() => NoteRepositoryImpl(sl()));
  sl.registerFactory(() => NotesCubit(sl()));

  // Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl(), sl()),
  );
  sl.registerFactory(() => ProfileCubit(sl()));
  sl.registerFactoryParam<ProfileEditCubit, AuthCubit, void>(
    (authCubit, _) => ProfileEditCubit(sl(), authCubit),
  );
  sl.registerFactory(() => MyCoursesCubit(sl()));
  sl.registerFactory(() => MyExamsCubit(sl()));

  // Announcements
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(sl()),
  );
  sl.registerFactory(() => AnnouncementsCubit(sl()));
  sl.registerFactory(() => AnnouncementDetailCubit(sl()));

  // Notifications — UnreadNotificationsCubit is a singleton so the badge
  // stays in sync across the home header and the full notifications list.
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerFactory(() => NotificationsCubit(sl()));
  sl.registerLazySingleton(() => UnreadNotificationsCubit(sl()));
  sl.registerLazySingleton(() => PushNotificationService(sl(), sl()));
}
