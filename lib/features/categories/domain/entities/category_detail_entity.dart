import 'package:equatable/equatable.dart';

import '../../../courses/domain/entities/course_entity.dart';
import 'category_entity.dart';

class CategoryDetailEntity extends Equatable {
  final CategoryEntity category;
  final List<CategoryEntity> children;
  final List<SubjectEntity> subjects;

  const CategoryDetailEntity({
    required this.category,
    this.children = const [],
    this.subjects = const [],
  });

  @override
  List<Object?> get props => [category, children, subjects];
}

class SubjectDetailEntity extends Equatable {
  final SubjectEntity subject;
  final List<CourseEntity> courses;

  const SubjectDetailEntity({required this.subject, this.courses = const []});

  @override
  List<Object?> get props => [subject, courses];
}
