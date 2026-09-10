import 'package:equatable/equatable.dart';

/// A single admin-uploaded schedule image for the student's class — used
/// for both the class schedule and the exam schedule, which share the
/// exact same shape.
class ScheduleEntity extends Equatable {
  final int id;
  final int? classId;
  final String imageUrl;

  const ScheduleEntity({
    required this.id,
    this.classId,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, classId, imageUrl];
}
