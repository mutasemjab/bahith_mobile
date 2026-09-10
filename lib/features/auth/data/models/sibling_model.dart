import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/sibling_entity.dart';

class SiblingModel extends SiblingEntity {
  const SiblingModel({
    required super.id,
    required super.name,
    super.avatar,
    super.className,
    super.classId,
  });

  factory SiblingModel.fromJson(Map<String, dynamic> json) => SiblingModel(
    id: toInt(json['id']),
    name: json['name'] ?? '',
    avatar: json['avatar'],
    className: relatedName(json['class']),
    classId: toIntOrNull(json['class_id']),
  );
}
