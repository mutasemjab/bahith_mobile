import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.avatar,
    super.className,
    super.classId,
    super.gender,
    super.dateOfBirth,
    super.nationality,
    super.appAccountToken,
    required super.isActive,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'],
    phone: json['phone'],
    avatar: json['avatar'],
    className: json['class'] is Map ? json['class']['name'] : json['class'],
    classId: json['class_id'],
    gender: json['gender'],
    dateOfBirth: json['date_of_birth'],
    nationality: json['nationality'],
    appAccountToken: json['app_account_token']?.toString(),
    isActive: json['is_active'] ?? true,
  );
}
