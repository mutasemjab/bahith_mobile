import 'package:equatable/equatable.dart';

class CourseLessonEntity extends Equatable {
  final int id;
  final String title;
  final int? durationMinutes;
  final bool isFree;
  final bool isCompleted;

  const CourseLessonEntity({
    required this.id,
    required this.title,
    this.durationMinutes,
    this.isFree = false,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, title];
}

class CourseUnitEntity extends Equatable {
  final int id;
  final String title;
  final List<CourseLessonEntity> lessons;

  const CourseUnitEntity({
    required this.id,
    required this.title,
    this.lessons = const [],
  });

  @override
  List<Object?> get props => [id, title, lessons];
}

class CourseEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? image;
  final int? teacherId;
  final String? teacherName;
  final String? teacherAvatar;
  final String? categoryName;
  final String? subjectName;
  final double? price;
  final double? oldPrice;
  final int? discountPercent;
  final bool isFree;
  final double rating;
  final int studentsCount;
  final int lessonsCount;
  final double? durationHours;
  final String? difficultyLevel;
  final bool featured;
  final bool trending;
  final bool isEnrolled;
  final double? progress;
  final List<CourseUnitEntity> units;

  const CourseEntity({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.teacherId,
    this.teacherName,
    this.teacherAvatar,
    this.categoryName,
    this.subjectName,
    this.price,
    this.oldPrice,
    this.discountPercent,
    this.isFree = false,
    this.rating = 0,
    this.studentsCount = 0,
    this.lessonsCount = 0,
    this.durationHours,
    this.difficultyLevel,
    this.featured = false,
    this.trending = false,
    this.isEnrolled = false,
    this.progress,
    this.units = const [],
  });

  CourseEntity copyWith({bool? isEnrolled, double? progress}) {
    return CourseEntity(
      id: id,
      title: title,
      description: description,
      image: image,
      teacherId: teacherId,
      teacherName: teacherName,
      teacherAvatar: teacherAvatar,
      categoryName: categoryName,
      subjectName: subjectName,
      price: price,
      oldPrice: oldPrice,
      discountPercent: discountPercent,
      isFree: isFree,
      rating: rating,
      studentsCount: studentsCount,
      lessonsCount: lessonsCount,
      durationHours: durationHours,
      difficultyLevel: difficultyLevel,
      featured: featured,
      trending: trending,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      progress: progress ?? this.progress,
      units: units,
    );
  }

  @override
  List<Object?> get props => [id, title, image, isEnrolled, progress];
}
