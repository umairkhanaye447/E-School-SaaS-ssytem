// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:eschool/utils/utils.dart';

class CustomTextFieldContainer extends StatefulWidget {
  final String hintTextKey;
  final bool hideText;
  final double? bottomPadding;
  final Widget? suffixWidget;

  /// Optional leading glyph. Tints to the primary colour while the field has
  /// focus, so the active field reads at a glance.
  final IconData? prefixIcon;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFieldContainer({
    Key? key,
    required this.hintTextKey,
    required this.hideText,
    this.bottomPadding,
    this.suffixWidget,
    this.prefixIcon,
    this.textEditingController,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomTextFieldContainer> createState() =>
      _CustomTextFieldContainerState();
}

class _CustomTextFieldContainerState extends State<CustomTextFieldContainer> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool focused = _focusNode.hasFocus;
    final Color primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: 50,
      margin: EdgeInsets.only(bottom: widget.bottomPadding ?? 20.0),
      padding: EdgeInsetsDirectional.only(
        start: widget.prefixIcon != null ? AppSpacing.sm : 20.0,
      ),
      //Filled field on a hairline border, matching inputDecorationTheme.
      //Focus swaps the hairline for the primary blue so the active field
      //reads immediately.
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: focused
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                  spreadRadius: -4,
                ),
              ]
            : AppShadows.card,
        borderRadius: AppRadius.fieldAll,
        border: Border.all(
          color: focused ? primary : AppColors.divider,
          width: focused ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(
              widget.prefixIcon,
              size: 20,
              color: focused ? primary : AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: TextField(
                controller: widget.textEditingController,
                focusNode: _focusNode,
                obscureText: widget.hideText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                enableInteractiveSelection: true,
                enableSuggestions: widget.keyboardType != TextInputType.number,
                autofocus: false,
                decoration: InputDecoration(
                  suffixIcon: widget.suffixWidget,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  hintText: Utils.getTranslatedLabel(widget.hintTextKey),
                  border: InputBorder.none,
                  contentPadding: widget.suffixWidget != null
                      ? const EdgeInsets.only(top: 12.5)
                      : null,
                )),
          ),
        ],
      ),
    );
  }
}
