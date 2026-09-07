import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../cubit/course_activation_cubit.dart';
import '../cubit/course_activation_state.dart';

/// Shows card-code activation only on platforms where commerce is enabled.
Future<void> showActivateCourseSheet({
  required BuildContext context,
  required int courseId,
  required VoidCallback onActivated,
}) {
  if (!AppSettingsScope.of(context).showCommerce) {
    return Future<void>.value();
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) =>
        _ActivateCourseSheet(courseId: courseId, onActivated: onActivated),
  );
}

class _ActivateCourseSheet extends StatefulWidget {
  final int courseId;
  final VoidCallback onActivated;

  const _ActivateCourseSheet({
    required this.courseId,
    required this.onActivated,
  });

  @override
  State<_ActivateCourseSheet> createState() => _ActivateCourseSheetState();
}

class _ActivateCourseSheetState extends State<_ActivateCourseSheet> {
  late final CourseActivationCubit _cubit = sl<CourseActivationCubit>();
  final _formKey = GlobalKey<FormState>();
  final _cardCodeController = TextEditingController();

  @override
  void dispose() {
    _cubit.close();
    _cardCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _cubit.activate(
      courseId: widget.courseId,
      cardCode: _cardCodeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: BlocConsumer<CourseActivationCubit, CourseActivationState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is CourseActivationSuccess) {
            Navigator.of(context).pop();
            widget.onActivated();
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تفعيل الدورة بالبطاقة',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'أدخل رمز البطاقة الموجود خلف بطاقة التفعيل',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cardCodeController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'XXXX-XXXX-XXXX',
                    errorText: state is CourseActivationError
                        ? state.message
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().length < 4
                      ? 'أدخل رمز البطاقة'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state is CourseActivationLoading ? null : _submit,
                  child: state is CourseActivationLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('تفعيل الآن'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
