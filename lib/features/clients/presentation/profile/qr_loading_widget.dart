import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';

class QRLoadingWidget extends StatefulWidget {
  final double? progress;
  
  const QRLoadingWidget({
    Key? key,
    this.progress,
  }) : super(key: key);

  @override
  State<QRLoadingWidget> createState() => _QRLoadingWidgetState();
}

class _QRLoadingWidgetState extends State<QRLoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Marco esquemático de un QR animado
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Esquinas del QR
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            border: Border(
                              right: BorderSide(color: AppTheme.primaryColor, width: 2),
                              bottom: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            border: Border(
                              left: BorderSide(color: AppTheme.primaryColor, width: 2),
                              bottom: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            border: Border(
                              right: BorderSide(color: AppTheme.primaryColor, width: 2),
                              top: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            border: Border(
                              left: BorderSide(color: AppTheme.primaryColor, width: 2),
                              top: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                      
                      // Elementos centrales
                      Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          color: AppTheme.primaryColor.withOpacity(
                            0.3 + (_animationController.value * 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progreso si hay progreso disponible
          if (widget.progress != null)
            Container(
              width: 100,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: widget.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 100,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          
          Text(
            'Cargando QR...',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}