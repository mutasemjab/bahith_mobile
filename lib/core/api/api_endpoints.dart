class ApiEndpoints {
  ApiEndpoints._();

  // static const baseUrl = 'https://bahith.mutasemjaber.online/api/v1/student';
  static const baseUrl = 'https://albahithacademy.com/api/v1/student';

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const deleteAccount = '/auth/delete-account';
  static String switchSibling(int siblingId) =>
      '/auth/switch-sibling/$siblingId';

  // App settings (public)
  static const appSettings = '/app-settings';

  // Student code of conduct
  static const conduct = '/conduct';
  static const conductStatus = '/conduct/status';
  static const conductSign = '/conduct/sign';

  // Home
  static const home = '/home';

  // Banners
  static const banners = '/banners';

  // Categories
  static const categories = '/categories';
  static String category(int id) => '/categories/$id';
  static String subject(int id) => '/subjects/$id';

  // Courses
  static const courses = '/courses';
  static String course(int id) => '/courses/$id';
  static String courseUnits(int id) => '/courses/$id/units';
  static String activateCourse(int id) => '/courses/$id/activate';
  static const verifyApplePurchase = '/purchases/apple/verify';
  static String courseMyProgress(int id) => '/courses/$id/my-progress';
  static String lesson(int id) => '/lessons/$id';
  static String lessonProgress(int id) => '/lessons/$id/progress';
  static String unitExams(int unitId) => '/units/$unitId/exams';

  // Teachers
  static const teachers = '/teachers';
  static String teacher(int id) => '/teachers/$id';

  // Exams
  static const exams = '/exams';
  static String exam(int id) => '/exams/$id';
  static String startExam(int id) => '/exams/$id/start';
  static String submitAttempt(int attemptId) => '/attempts/$attemptId/submit';

  // Resources
  static const previousYearExams = '/previous-year-exams';
  static String previousYearExam(int id) => '/previous-year-exams/$id';
  static const questionBanks = '/question-banks';
  static String questionBank(int id) => '/question-banks/$id';
  static const worksheets = '/worksheets';
  static String worksheet(int id) => '/worksheets/$id';

  // Profile
  static const profile = '/profile';
  static const myCourses = '/my-courses';
  static const myExams = '/my-exams';

  // Educational Notes
  static const educationalNotes = '/educational-notes';

  // Planner & schedules
  static const weeklyPlanner = '/weekly-planner';
  static const classSchedule = '/class-schedule';
  static const examSchedule = '/exam-schedule';

  // Announcements
  static const announcements = '/announcements';
  static String announcement(int id) => '/announcements/$id';

  // Notifications
  static const notifications = '/notifications';
  static String markNotificationRead(int id) => '/notifications/$id/read';
  static const markAllNotificationsRead = '/notifications/read-all';
  static const deviceToken = '/device-token';
}
