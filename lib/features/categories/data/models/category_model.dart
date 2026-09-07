import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.image,
    super.icon,
    super.subcategoriesCount,
    super.coursesCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'] ?? json['name_ar'] ?? json['name_en'] ?? '',
    image: json['image'],
    icon: json['icon'],
    // `subcategories_count` on the categories list vs. `has_children`
    // (a count, despite the boolean-sounding name, or null) on detail.
    subcategoriesCount:
        json['subcategories_count'] ??
        (json['has_children'] is int ? json['has_children'] as int : 0),
    coursesCount: json['courses_count'] ?? 0,
  );
}

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.name,
    super.image,
    super.coursesCount,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'],
    name: json['name'] ?? json['name_ar'] ?? json['name_en'] ?? '',
    image: json['image'],
    coursesCount: json['courses_count'] ?? 0,
  );
}
