import 'package:equatable/equatable.dart';

import '../../domain/entities/home_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeEntity home;
  const HomeLoaded(this.home);
  @override
  List<Object?> get props => [home];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
