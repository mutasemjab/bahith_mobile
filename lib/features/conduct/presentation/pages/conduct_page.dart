import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/conduct_cubit.dart';
import '../cubit/conduct_state.dart';

class ConductPage extends StatelessWidget {
  const ConductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ConductCubit>()..load(),
      child: const _ConductView(),
    );
  }
}

class _ConductView extends StatefulWidget {
  const _ConductView();

  @override
  State<_ConductView> createState() => _ConductViewState();
}

class _ConductViewState extends State<_ConductView> {
  final _scrollController = ScrollController();
  final _guardianController = TextEditingController();
  bool _reachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkReachedEnd);
    _guardianController.addListener(_refreshButton);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_checkReachedEnd)
      ..dispose();
    _guardianController
      ..removeListener(_refreshButton)
      ..dispose();
    super.dispose();
  }

  void _refreshButton() {
    if (mounted) setState(() {});
  }

  void _checkReachedEnd() {
    if (_reachedEnd || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 8 ||
        position.pixels >= position.maxScrollExtent - 16) {
      setState(() => _reachedEnd = true);
    }
  }

  void _checkShortDocument() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkReachedEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocConsumer<ConductCubit, ConductState>(
        listener: (context, state) async {
          if (state is ConductLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.accent,
                ),
              );
          }

          if (state is ConductSignSuccess) {
            await context.read<AuthCubit>().completeConductSignature();
            if (context.mounted) context.go('/home');
          }
        },
        builder: (context, state) {
          final document = state is ConductLoaded ? state.document : null;
          final submitting = state is ConductLoaded && state.submitting;
          if (document != null) _checkShortDocument();

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
              title: Text(
                document?.titleAr ?? 'مدونة السلوك',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: switch (state) {
              ConductLoading() => const LoadingWidget(),
              ConductLoadError(:final message) => AppErrorView(
                message: message,
                onRetry: context.read<ConductCubit>().load,
              ),
              ConductLoaded() => SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                          child: SelectableText(
                            document!.body,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.9,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Container(
                      color: AppColors.card,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _guardianController,
                            label: 'اسم ولي الأمر',
                            hint: 'أدخل اسم ولي الأمر كاملاً',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(200),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                _reachedEnd
                                    ? Icons.check_circle_rounded
                                    : Icons.swipe_up_rounded,
                                size: 17,
                                color: _reachedEnd
                                    ? AppColors.success
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  _reachedEnd
                                      ? 'تمت قراءة المدونة حتى النهاية'
                                      : 'مرّر النص حتى النهاية لتفعيل الموافقة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _reachedEnd
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed:
                                _reachedEnd &&
                                    _guardianController.text
                                        .trim()
                                        .isNotEmpty &&
                                    !submitting
                                ? () => context.read<ConductCubit>().sign(
                                    _guardianController.text.trim(),
                                  )
                                : null,
                            child: submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('أوافق وأُقرّ بالالتزام'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ConductSignSuccess() => const LoadingWidget(),
            },
          );
        },
      ),
    );
  }
}
