import 'package:equatable/equatable.dart';

abstract class CourseActivationState extends Equatable {
  const CourseActivationState();
  @override
  List<Object?> get props => [];
}

class CourseActivationInitial extends CourseActivationState {
  const CourseActivationInitial();
}

class CourseActivationLoading extends CourseActivationState {
  const CourseActivationLoading();
}

class CourseActivationSuccess extends CourseActivationState {
  const CourseActivationSuccess();
}

class CourseActivationError extends CourseActivationState {
  final String message;
  const CourseActivationError(this.message);
  @override
  List<Object?> get props => [message];
}
