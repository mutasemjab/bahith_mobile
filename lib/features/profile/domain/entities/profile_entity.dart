import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/student_entity.dart';

class ProfileStatsEntity extends Equatable {
  final int coursesCount;
  final int examsCount;
  final double averageScore;

  const ProfileStatsEntity({
    this.coursesCount = 0,
    this.examsCount = 0,
    this.averageScore = 0,
  });

  @override
  List<Object?> get props => [coursesCount, examsCount, averageScore];
}

class ProfileEntity extends Equatable {
  final StudentEntity student;
  final ProfileStatsEntity stats;

  const ProfileEntity({required this.student, required this.stats});

  @override
  List<Object?> get props => [student, stats];
}
