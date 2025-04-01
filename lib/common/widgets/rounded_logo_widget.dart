import 'package:flutter/material.dart';
import 'package:BCG_Store/common/services/theme_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:get/get.dart';

class RoundedLogoWidget extends StatelessWidget {
  final double height;
  
  final double? width;
  
  final double borderRadius;
  
  final Color? backgroundColor; 
  final EdgeInsetsGeometry? padding;
  
  final BoxFit fit;
  
  final Widget Function(BuildContext, Object, StackTrace?)? customErrorBuilder;
  
  final String? customUrl;

  const RoundedLogoWidget({
    Key? key,
    required this.height,
    this.width,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.padding,
    this.fit = BoxFit.contain,
    this.customErrorBuilder,
    this.customUrl,
  }) : super(key: key);
 @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = customUrl ?? 
                 (ThemeService.to.logoUrl.value.isNotEmpty
                  ? ThemeService.to.logoUrl.value
                  : AppTheme.defaultLogoAsset);
      
      return Container(
        padding: padding,
        constraints: BoxConstraints(
          maxWidth: width ?? MediaQuery.of(context).size.width * 0.7, // Limita el ancho máximo
          maxHeight: height,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            url,
            fit: fit,
            errorBuilder: customErrorBuilder ?? (context, error, stackTrace) {
              print('Error cargando imagen: $error');
              return ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Image.network(
                  AppTheme.defaultLogoAsset,
                  fit: fit,
                ),
              );
            },
          ),
        ),
      );
    });
  }
}