import 'package:equatable/equatable.dart';

/// A subject as referenced from a class-scoped resource list (question
/// banks, previous-year exams, worksheets) — just enough to drive a
/// subject picker before filtering that list by `subject_id`.
class SubjectRef extends Equatable {
  final int id;
  final String name;

  const SubjectRef({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
