import 'package:equatable/equatable.dart';

/// The latest weekly planner image for the student's class and date window
/// — the server resolves both, the app just displays whatever comes back.
class WeeklyPlannerEntity extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;

  const WeeklyPlannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, startDate, endDate];
}
