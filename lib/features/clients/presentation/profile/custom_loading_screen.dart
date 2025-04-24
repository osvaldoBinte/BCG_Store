import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class CustomLoadingScreen extends StatefulWidget {
  final String? message;
  
  const CustomLoadingScreen({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  State<CustomLoadingScreen> createState() => _CustomLoadingScreenState();
}

class _CustomLoadingScreenState extends State<CustomLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi * (index % 2 == 0 ? 1 : -1),
                        child: Container(
                          width: 120 - (index * 20),
                          height: 120 - (index * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.8 - (index * 0.2)),
                              width: 4,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                
                // Logo o icono en el centro
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: AppTheme.secondaryColor,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Indicador de progreso lineal animado
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mensaje personalizable
          Text(
            widget.message ?? 'Cargando puntos...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}