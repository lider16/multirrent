import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonType = ButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height,
    this.fontSize,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonType buttonType;
  final bool isLoading;
  final double? width;
  final double? height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.onPrimary,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: fontSize ?? AppConstants.buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    Color backgroundColor;
    Color foregroundColor;

    switch (buttonType) {
      case ButtonType.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.onPrimary;
        break;
      case ButtonType.secondary:
        backgroundColor = AppColors.secondary;
        foregroundColor = AppColors.onSecondary;
        break;
      case ButtonType.error:
        backgroundColor = AppColors.error;
        foregroundColor = AppColors.onError;
        break;
      case ButtonType.strongPrimary:
        backgroundColor = AppColors.primaryStrong;
        foregroundColor = AppColors.onPrimary;
        break;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
    );
  }
}

enum ButtonType { primary, secondary, error, strongPrimary }
