import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'widgets/auth_brand_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const AuthBrandHeader(
                    title: 'مرحباً بعودتك',
                    subtitle: 'سجّل الدخول لمتابعة رحلتك التعليمية',
                  ),
                  const SizedBox(height: 36),
                  AppTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    hint: '07xxxxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => (v == null || v.trim().length < 8)
                        ? 'أدخل رقم هاتف صحيح'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'كلمة المرور 6 أحرف على الأقل'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
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
                            : const Text('تسجيل الدخول'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('إنشاء حساب جديد'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
