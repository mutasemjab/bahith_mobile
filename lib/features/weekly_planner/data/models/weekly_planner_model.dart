import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/weekly_planner_entity.dart';

class WeeklyPlannerModel extends WeeklyPlannerEntity {
  const WeeklyPlannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    super.startDate,
    super.endDate,
  });

  /// `data` is null when no planner currently matches the student's class
  /// and date window — a normal response, not an error.
  static WeeklyPlannerModel? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final image = json['image'] as String?;
    if (image == null || image.isEmpty) return null;
    return WeeklyPlannerModel(
      id: toInt(json['id']),
      title: json['title'] ?? '',
      imageUrl: image,
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? ''),
    );
  }
}
