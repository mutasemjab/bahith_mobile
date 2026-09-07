import 'package:equatable/equatable.dart';

import '../../../courses/domain/entities/course_entity.dart';
import 'teacher_entity.dart';

class TeacherDetailEntity extends Equatable {
  final TeacherEntity teacher;
  final List<CourseEntity> courses;

  const TeacherDetailEntity({required this.teacher, this.courses = const []});

  @override
  List<Object?> get props => [teacher, courses];
}
