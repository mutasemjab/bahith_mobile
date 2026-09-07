import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final String? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.isRead = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, isRead];
}
