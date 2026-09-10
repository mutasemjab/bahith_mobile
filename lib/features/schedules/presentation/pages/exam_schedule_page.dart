import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/schedule_entity.dart';
import '../cubit/exam_schedule_cubit.dart';
import '../widgets/schedule_view.dart';

class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  late final ExamScheduleCubit _cubit = sl<ExamScheduleCubit>()..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جدول الامتحانات')),
      body: BlocBuilder<ExamScheduleCubit, ResourceState<ScheduleEntity?>>(
        bloc: _cubit,
        builder: (context, state) => ScheduleView(
          state: state,
          onRetry: _cubit.load,
          emptyMessage: 'لم يتم رفع جدول الامتحانات لهذا الصف بعد',
        ),
      ),
    );
  }
}
