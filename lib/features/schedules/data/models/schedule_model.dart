import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    super.classId,
    required super.imageUrl,
  });

  /// The API returns `data: null` (with an explanatory `message`) when no
  /// image has been uploaded yet for the student's class — that's a normal,
  /// non-error response, so this returns null rather than throwing.
  static ScheduleModel? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final image = json['image'] as String?;
    if (image == null || image.isEmpty) return null;
    return ScheduleModel(
      id: toInt(json['id']),
      classId: toIntOrNull(json['class_id']),
      imageUrl: image,
    );
  }
}
