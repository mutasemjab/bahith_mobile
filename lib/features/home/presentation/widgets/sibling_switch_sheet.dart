import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/domain/entities/sibling_entity.dart';
import '../../../auth/domain/entities/student_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// One-tap account switcher between a student and their linked siblings.
/// Switching replaces the stored session token/student and lets the router
/// redirect (conduct gate included) react to the new [AuthCubit] state.
Future<void> showSiblingSwitchSheet(
  BuildContext context,
  StudentEntity student,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => _SiblingSwitchSheet(
      authCubit: context.read<AuthCubit>(),
      student: student,
    ),
  );
}

class _SiblingSwitchSheet extends StatefulWidget {
  final AuthCubit authCubit;
  final StudentEntity student;

  const _SiblingSwitchSheet({required this.authCubit, required this.student});

  @override
  State<_SiblingSwitchSheet> createState() => _SiblingSwitchSheetState();
}

class _SiblingSwitchSheetState extends State<_SiblingSwitchSheet> {
  int? _switchingId;
  String? _error;

  Future<void> _switchTo(SiblingEntity sibling) async {
    setState(() {
      _switchingId = sibling.id;
      _error = null;
    });

    final error = await widget.authCubit.switchSibling(sibling.id);
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _switchingId = null;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final switching = _switchingId != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
          const Text(
            'تبديل الحساب',
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _SiblingRow(
            name: widget.student.name,
            avatar: widget.student.avatar,
            className: widget.student.className,
            selected: true,
            loading: false,
            onTap: null,
          ),
          if (widget.student.siblings.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...widget.student.siblings.map(
              (sibling) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _SiblingRow(
                  name: sibling.name,
                  avatar: sibling.avatar,
                  className: sibling.className,
                  selected: false,
                  loading: _switchingId == sibling.id,
                  onTap: switching ? null : () => _switchTo(sibling),
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SiblingRow extends StatelessWidget {
  final String name;
  final String? avatar;
  final String? className;
  final bool selected;
  final bool loading;
  final VoidCallback? onTap;

  const _SiblingRow({
    required this.name,
    required this.avatar,
    required this.className,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.06)
          : AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: AppNetworkImage(
                  url: avatar,
                  width: 44,
                  height: 44,
                  radius: 999,
                  fallbackIcon: Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (className != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        className!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              else if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                )
              else
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
