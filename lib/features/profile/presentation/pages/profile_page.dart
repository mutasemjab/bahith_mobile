import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/profile_entity.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: BlocBuilder<ProfileCubit, ResourceState<ProfileEntity>>(
          builder: (context, state) {
            if (state is ResourceLoading) return const LoadingWidget();
            if (state is ResourceError<ProfileEntity>) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<ProfileCubit>().load(),
              );
            }
            final profile = (state as ResourceLoaded<ProfileEntity>).data;
            final student = profile.student;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ProfileCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: AppNetworkImage(
                            url: student.avatar,
                            width: 80,
                            height: 80,
                            radius: 999,
                            fallbackIcon: Icons.person_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (student.email != null &&
                            student.email!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            student.email!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        if (student.className != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              student.className!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.menu_book_rounded,
                          value: profile.stats.coursesCount.arDigits,
                          label: 'دوراتي',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.quiz_rounded,
                          value: profile.stats.examsCount.arDigits,
                          label: 'اختباراتي',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.trending_up_rounded,
                          value:
                              '${profile.stats.averageScore.toStringAsFixed(0)}٪',
                          label: 'المعدل',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _MenuTile(
                    icon: Icons.menu_book_rounded,
                    label: 'دوراتي',
                    onTap: () => context.push('/my-courses'),
                  ),
                  _MenuTile(
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'اختباراتي',
                    onTap: () => context.push('/my-exams'),
                  ),
                  _MenuTile(
                    icon: Icons.sticky_note_2_rounded,
                    label: 'الملاحظات التعليمية',
                    onTap: () => context.push('/educational-notes'),
                  ),
                  _MenuTile(
                    icon: Icons.folder_copy_rounded,
                    label: 'الملفات',
                    onTap: () => context.push('/files'),
                  ),
                  _MenuTile(
                    icon: Icons.edit_rounded,
                    label: 'تعديل الملف الشخصي',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    label: 'تسجيل الخروج',
                    color: AppColors.accent,
                    onTap: () => _confirmLogout(context),
                  ),
                  _MenuTile(
                    icon: Icons.delete_forever_rounded,
                    label: 'حذف الحساب',
                    color: Colors.red.shade700,
                    onTap: () => _confirmDeleteAccount(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _DeleteAccountDialog(authCubit: context.read<AuthCubit>()),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final AuthCubit authCubit;

  const _DeleteAccountDialog({required this.authCubit});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _deleting = false;
  String? _error;

  Future<void> _deleteAccount() async {
    setState(() {
      _deleting = true;
      _error = null;
    });

    final error = await widget.authCubit.deleteAccount();
    if (!mounted || error == null) return;

    setState(() {
      _deleting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_deleting,
      child: AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red.shade700,
          size: 36,
        ),
        title: const Text('حذف الحساب نهائياً'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'هل أنت متأكد؟ سيتم حذف حسابك وتسجيل خروجك من جميع الأجهزة، ولن تتمكن من استخدام الحساب بعد ذلك.',
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _deleting ? null : () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: _deleting ? null : _deleteAccount,
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: _deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: tileColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tileColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
