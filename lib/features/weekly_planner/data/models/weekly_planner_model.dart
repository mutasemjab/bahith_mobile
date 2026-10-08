import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/weekly_planner_entity.dart';

class WeeklyPlannerModel extends WeeklyPlannerEntity {
  const WeeklyPlannerModel({
    required super.id,
    required super.title,
    required super.imageArUrl,
    required super.imageEnUrl,
    super.startDate,
    super.endDate,
  });

  /// `data` is null when no planner currently matches the student's class
  /// and date window — a normal response, not an error. `image_ar`/
  /// `image_en` are always both present when `data` isn't null; `image`
  /// (mirrors `image_ar`) is only kept here as a fallback for a response
  /// that hasn't rolled out the new fields yet.
  static WeeklyPlannerModel? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final legacyImage = json['image'] as String?;
    final imageAr = json['image_ar'] as String? ?? legacyImage;
    final imageEn = json['image_en'] as String? ?? imageAr;
    if (imageAr == null || imageAr.isEmpty) return null;
    return WeeklyPlannerModel(
      id: toInt(json['id']),
      title: json['title'] ?? '',
      imageArUrl: imageAr,
      imageEnUrl: imageEn!,
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? ''),
    );
  }
}
