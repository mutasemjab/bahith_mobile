import 'package:equatable/equatable.dart';

/// The latest weekly planner for the student's class and date window — the
/// server resolves both, the app just displays whatever comes back. There
/// are always two images, Arabic and English (the server duplicates the
/// Arabic one into [imageEnUrl] when no English version was uploaded).
class WeeklyPlannerEntity extends Equatable {
  final int id;
  final String title;
  final String imageArUrl;
  final String imageEnUrl;
  final DateTime? startDate;
  final DateTime? endDate;

  const WeeklyPlannerEntity({
    required this.id,
    required this.title,
    required this.imageArUrl,
    required this.imageEnUrl,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    imageArUrl,
    imageEnUrl,
    startDate,
    endDate,
  ];
}
