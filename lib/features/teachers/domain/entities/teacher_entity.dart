import 'package:equatable/equatable.dart';

class TeacherEntity extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final String? bio;
  final String? specialization;
  final int coursesCount;
  final double rating;

  const TeacherEntity({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.specialization,
    this.coursesCount = 0,
    this.rating = 0,
  });

  @override
  List<Object?> get props => [id, name, avatar];
}
