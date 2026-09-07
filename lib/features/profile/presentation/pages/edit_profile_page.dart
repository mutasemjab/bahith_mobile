import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/student_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../cubit/profile_edit_cubit.dart';
import '../cubit/profile_edit_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileEditCubit _cubit = sl<ProfileEditCubit>(
    param1: context.read<AuthCubit>(),
  );

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _gender;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final student = authState is AuthAuthenticated ? authState.student : null;
    _nameController = TextEditingController(text: student?.name ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _gender = student?.gender;
  }

  @override
  void dispose() {
    _cubit.close();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    _cubit.save(
      UpdateProfilePayload(
        name: _nameController.text.trim(),
        email: email.isEmpty ? null : email,
        phone: _phoneController.text.trim(),
        gender: _gender,
        avatar: _avatarFile,
        currentPassword: _currentPasswordController.text.isEmpty
            ? null
            : _currentPasswordController.text,
        password: _newPasswordController.text.isEmpty
            ? null
            : _newPasswordController.text,
        passwordConfirmation: _confirmPasswordController.text.isEmpty
            ? null
            : _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final StudentEntity? student = authState is AuthAuthenticated
        ? authState.student
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: BlocListener<ProfileEditCubit, ProfileEditState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is ProfileEditSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الملف الشخصي بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ProfileEditError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.accent,
                ),
              );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: _avatarFile != null
                            ? Image.file(
                                _avatarFile!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              )
                            : AppNetworkImage(
                                url: student?.avatar,
                                width: 96,
                                height: 96,
                                radius: 999,
                                fallbackIcon: Icons.person_rounded,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'أدخل اسماً صحيحاً'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني (اختياري)',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v != null && v.trim().isNotEmpty && !v.contains('@'))
                      ? 'أدخل بريداً إلكترونياً صحيحاً'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Text(
                  'الجنس',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'ذكر',
                        selected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GenderOption(
                        label: 'أنثى',
                        selected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'تغيير كلمة المرور (اختياري)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'كلمة المرور الحالية',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'كلمة المرور الجديدة',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور الجديدة',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: (v) =>
                      (_newPasswordController.text.isNotEmpty &&
                          v != _newPasswordController.text)
                      ? 'كلمتا المرور غير متطابقتين'
                      : null,
                ),
                const SizedBox(height: 28),
                BlocBuilder<ProfileEditCubit, ProfileEditState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    final loading = state is ProfileEditSaving;
                    return ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('حفظ التغييرات'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
