import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/schedule_entity.dart';
import '../cubit/class_schedule_cubit.dart';
import '../widgets/schedule_view.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  late final ClassScheduleCubit _cubit = sl<ClassScheduleCubit>()..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جدول الحصص')),
      body: BlocBuilder<ClassScheduleCubit, ResourceState<ScheduleEntity?>>(
        bloc: _cubit,
        builder: (context, state) => ScheduleView(
          state: state,
          onRetry: _cubit.load,
          emptyMessage: 'لم يتم رفع جدول الحصص لهذا الصف بعد',
        ),
      ),
    );
  }
}
