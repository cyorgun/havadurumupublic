import '../../../colors/app_colors.dart';
import '../../../dimens/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveCustomTextField<T> extends StatefulWidget {
  final FormControl<T>? formControl;
  final String? formControlName;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconButton? suffixIcon;
  final TextInputType? keyboardType;
  final bool isMandatory;
  final bool obscureText;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final Function(FormControl)? onTap;
  final Function(FormControl)? onSubmitted;
  final ValueChanged<bool>? onFocusChange;
  final bool showError;
  final double? textHeight;

  const ReactiveCustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.formControl,
    this.formControlName,
    this.isMandatory = true,
    this.obscureText = false,
    this.autocorrect = false,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.onFocusChange,
    this.showError = false,
    this.textHeight,
  })  : assert(formControl != null || formControlName != null,
  'One between FormControl or FormControlName must not be null.');

  @override
  _ReactiveCustomTextFieldState<T> createState() =>
      _ReactiveCustomTextFieldState<T>();
}

class _ReactiveCustomTextFieldState<T>
    extends State<ReactiveCustomTextField<T>> {
  Color _colorText = AppColors.textFieldColor;
  FontWeight _fontWeightText = FontWeight.w200;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: _onFocusChange,
      child: ReactiveTextField(
        autocorrect: widget.autocorrect,
        style: TextStyle(
          height: widget.textHeight,
          color: AppColors.textButtonColor,
          fontWeight: FontWeight.bold,
        ),
        formControl: widget.formControl,
        formControlName: widget.formControlName,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        onTap: widget.onTap,
        showErrors: (control) => widget.showError && control.invalid,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          focusColor: AppColors.textButtonColor,
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _colorText,
            fontWeight: _fontWeightText,
            fontSize: Dimens.medium2FontSize,
          ),
          fillColor: Colors.transparent,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: AppColors.inputIconColor),
          suffixIcon: widget.suffixIcon,
          hintText: widget.hintText,
        ),
      ),
    );
  }

  void _onFocusChange(bool hasFocus) {
    _changeColor(hasFocus);
    widget.onFocusChange?.call(hasFocus);
  }

  void _changeColor(hasFocus) {
    setState(() {
      _colorText = hasFocus
          ? AppColors.textFieldColor
          : widget.isMandatory
          ? AppColors.textFieldColor
          : AppColors.textFieldColor.withOpacity(.5);
      _fontWeightText = hasFocus ? FontWeight.normal : FontWeight.w200;
    });
  }
}
