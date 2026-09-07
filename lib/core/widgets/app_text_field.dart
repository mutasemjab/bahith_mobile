import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, size: 20, color: AppColors.textMuted)
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
