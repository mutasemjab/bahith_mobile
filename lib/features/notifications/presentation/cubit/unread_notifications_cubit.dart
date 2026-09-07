import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notification_repository.dart';

/// App-wide badge count, kept as a singleton so the bell icon anywhere in
/// the shell stays in sync without re-fetching per screen.
class UnreadNotificationsCubit extends Cubit<int> {
  final NotificationRepository _repository;
  UnreadNotificationsCubit(this._repository) : super(0);

  Future<void> refresh() async {
    final result = await _repository.getUnreadCount();
    result.fold((_) {}, (count) => emit(count));
  }

  Future<void> markOneRead(int notificationId) async {
    await _repository.markRead(notificationId);
    if (state > 0) emit(state - 1);
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    emit(0);
  }

  void reset() => emit(0);
}
