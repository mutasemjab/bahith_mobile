import 'package:equatable/equatable.dart';

class SiblingEntity extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final String? className;
  final int? classId;

  const SiblingEntity({
    required this.id,
    required this.name,
    this.avatar,
    this.className,
    this.classId,
  });

  @override
  List<Object?> get props => [id, name, avatar, className, classId];
}
