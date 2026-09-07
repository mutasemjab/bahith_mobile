import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? image;
  final String? icon;
  final int subcategoriesCount;
  final int coursesCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.image,
    this.icon,
    this.subcategoriesCount = 0,
    this.coursesCount = 0,
  });

  @override
  List<Object?> get props => [id, name, image];
}

class SubjectEntity extends Equatable {
  final int id;
  final String name;
  final String? image;
  final int coursesCount;

  const SubjectEntity({
    required this.id,
    required this.name,
    this.image,
    this.coursesCount = 0,
  });

  @override
  List<Object?> get props => [id, name];
}
