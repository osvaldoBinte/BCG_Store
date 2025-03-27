import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/page/widgets/animated_success_check.dart';

enum CustomAlertType { info, confirm, warning, success, error }

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? imagePath;
  final CustomAlertType type;
  final Widget? customWidget;
  // Campos adicionales para el tipo info
  final String? driverName;
  final String? rating;
  final String? carModel;
  final String? licensePlate;
  final int? totalTrips;
  final String? profileImageUrl;
 
  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.imagePath,
    required this.type,
    this.customWidget,
    this.driverName,
    this.rating,
    this.carModel,
    this.licensePlate,
    this.totalTrips,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.85;
          return Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            child: type == CustomAlertType.info
                ? _buildInfoDialog(context)
                : _buildStandardDialog(context),
          );
        },
      ),
    );
  }

  Widget _buildInfoDialog(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Foto de perfil con calificación
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? Text(driverName?.substring(0, 1).toUpperCase() ?? 'U')
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(rating ?? '0.0'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              // Información del conductor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      licensePlate ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${totalTrips ?? 0} viajes',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Información del vehículo
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  imagePath ?? 'assets/images/viajes/taxi.png',
                  width: 100,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    carModel ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, 
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              child: Text(
                confirmText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStandardDialog(BuildContext context) {
    Color headerColor;
    Widget headerContent;
    
    switch (type) {
      case CustomAlertType.success:
        headerColor = AppTheme.successColor;
        headerContent = const AnimatedSuccessCheck();
        break;
      case CustomAlertType.error:
        headerColor = AppTheme.errorColor;
        headerContent = const AnimatedExclamationMark();
        break;
      case CustomAlertType.warning:
        headerColor = AppTheme.primaryColor;
        headerContent = const AnimatedShoppingCart(); 
        break;
      case CustomAlertType.confirm:
      default:
        headerColor = AppTheme.primaryColor;
        headerContent = const AnimatedExclamationMark();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (no scrolleable)
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(child: headerContent),
          ),
          
          // Contenido (scrolleable)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título y mensaje
                  if (title.isNotEmpty || message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (title.isNotEmpty) 
                            Text(
                              title,
                              style: AppTheme.theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: type == CustomAlertType.success 
                                    ? AppTheme.successColor
                                    : type == CustomAlertType.error 
                                        ? AppTheme.errorColor
                                        : AppTheme.textTertiaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (title.isNotEmpty && message.isNotEmpty)
                            const SizedBox(height: 8),
                          if (message.isNotEmpty)
                            Text(
                              message,
                              style: AppTheme.theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    
                  // Widget personalizado
                  if (customWidget != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: customWidget!,
                    ),
                ],
              ),
            ),
          ),
          
          // Botones (no scrolleable)
          if ((confirmText.isNotEmpty || cancelText?.isNotEmpty == true) &&
              customWidget == null)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: _buildButtons(context),
            ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    // Determinar el color del botón según el tipo de alerta
    final buttonColor = type == CustomAlertType.error
        ? AppTheme.errorColor 
        : type == CustomAlertType.success
            ? AppTheme.successColor
            : AppTheme.primaryColor;
        
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (cancelText != null) ...[
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(0, 40),
                foregroundColor: AppTheme.textSecondaryColor,
              ),
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(
                cancelText!,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              minimumSize: Size(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget de animación del carrito de compras
class AnimatedShoppingCart extends StatefulWidget {
  const AnimatedShoppingCart({Key? key}) : super(key: key);

  @override
  _AnimatedShoppingCartState createState() => _AnimatedShoppingCartState();
}

class _AnimatedShoppingCartState extends State<AnimatedShoppingCart>
    with TickerProviderStateMixin {
  late AnimationController _cartController;
  late AnimationController _itemsController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  final List<ShoppingItem> _items = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateItems();
    _startAnimation();
  }

  void _initializeAnimations() {
    _cartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -10)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -6)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -6, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
    ]).animate(_cartController);

    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _cartController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _generateItems() {
    // Generar diferentes ítems para el carrito
    _items.add(ShoppingItem(
      icon: Icons.checkroom,
      color: Colors.orange,
      offset: const Offset(-20, -25),
    ));
    _items.add(ShoppingItem(
      icon: Icons.shopping_bag,
      color: Colors.green,
      offset: const Offset(0, -30),
    ));
    _items.add(ShoppingItem(
      icon: Icons.local_grocery_store,
      color: Colors.red,
      offset: const Offset(20, -25),
    ));
  }

  void _startAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      _cartController.forward();
      await Future.delayed(const Duration(milliseconds: 1500));
      _cartController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Carrito base
        AnimatedBuilder(
          animation: _cartController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Icon(
                  Icons.shopping_cart,
                  size: 56,
                  color: AppTheme.secondaryColor, // Usamos el tema personalizado
                ),
              ),
            );
          },
        ),
        // Ítems que flotan alrededor del carrito
        ..._buildItems(),
      ],
    );
  }

  List<Widget> _buildItems() {
    return _items.map((item) {
      return AnimatedBuilder(
        animation: _itemsController,
        builder: (context, child) {
          // Calcular una posición ondulante para cada ítem
          final wave = math.sin(_itemsController.value * math.pi * 2);
          final verticalOffset = wave * 10; // Movimiento vertical
          
          return Positioned(
            top: item.offset.dy + verticalOffset,
            left: item.offset.dx,
            child: Opacity(
              opacity: 0.8,
              child: Icon(
                item.icon,
                size: 24,
                color: item.color.withOpacity(0.9),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _cartController.dispose();
    _itemsController.dispose();
    super.dispose();
  }
}

class ShoppingItem {
  final IconData icon;
  final Color color;
  final Offset offset;

  ShoppingItem({
    required this.icon,
    required this.color,
    required this.offset,
  });
}

class AnimatedExclamationMark extends StatefulWidget {
  const AnimatedExclamationMark({Key? key}) : super(key: key);

  @override
  _AnimatedExclamationMarkState createState() => _AnimatedExclamationMarkState();
}

class _AnimatedExclamationMarkState extends State<AnimatedExclamationMark>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorAnimation;
  final List<Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.1)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      _particles.add(Particle(
        speed: random.nextDouble() * 2 + 1,
        theta: random.nextDouble() * math.pi * 2,
        radius: random.nextDouble() * 20 + 10,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Particles
        ..._buildParticles(),
        // Main exclamation mark
        AnimatedBuilder(
          animation: Listenable.merge([_mainController, _colorAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Text(
                  '¡',
                  style: TextStyle(
                    color: _colorAnimation.value,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final progress = _particleController.value;
          final opacity = (1 - progress).clamp(0.0, 1.0);
          final scale = (1 - progress * 0.5).clamp(0.0, 1.0);
          
          return Positioned(
            left: math.cos(particle.theta) * particle.radius * progress * 2,
            top: math.sin(particle.theta) * particle.radius * progress * 2,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

class Particle {
  final double speed;
  final double theta;
  final double radius;

  Particle({
    required this.speed,
    required this.theta,
    required this.radius,
  });
}

// Clase SuccessParticle (para la animación de éxito)
class SuccessParticle {
  final Color color;
  final double angle;
  final double distance;
  final double size;
  final double duration;

  SuccessParticle({
    required this.color,
    required this.angle,
    required this.distance,
    required this.size,
    required this.duration,
  });
}

// Nueva animación de check para alertas de éxito
class AnimatedSuccessCheck extends StatefulWidget {
  const AnimatedSuccessCheck({Key? key}) : super(key: key);

  @override
  _AnimatedSuccessCheckState createState() => _AnimatedSuccessCheckState();
}

class _AnimatedSuccessCheckState extends State<AnimatedSuccessCheck>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _circleController;
  late AnimationController _particlesController;
  late Animation<double> _checkAnimation;
  late Animation<double> _circleAnimation;
  late Animation<double> _scaleAnimation;
  final List<SuccessParticle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Animación del círculo
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _circleAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    );

    // Animación del check
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutCubic,
    );

    // Animación de partículas
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animación de escala para efecto de rebote
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_circleController);
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      final double angle = i * (math.pi * 2) / 12;
      _particles.add(SuccessParticle(
        color: AppTheme.successColor,
        angle: angle,
        distance: random.nextDouble() * 15 + 25,
        size: random.nextDouble() * 5 + 3,
        duration: random.nextDouble() * 0.3 + 0.7,
      ));
    }
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _particlesController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Partículas
          ..._buildParticles(),
          
          // Círculo principal
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Check mark
          AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(30, 30),
                painter: CheckPainter(
                  progress: _checkAnimation.value,
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _particlesController,
        builder: (context, child) {
          final progress = _particlesController.value;
          final distance = particle.distance * progress;
          final opacity = (1 - progress) * particle.duration;
          
          return Positioned(
            left: 50 + (math.cos(particle.angle) * distance),
            top: 50 + (math.sin(particle.angle) * distance),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withOpacity(0.5),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _circleController.dispose();
    _particlesController.dispose();
    super.dispose();
  }
}


void showCustomAlert({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? imagePath,
    required CustomAlertType type,
    Widget? customWidget,
  }) {
 showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: CustomAlertDialog(
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                onConfirm: onConfirm,
                onCancel: onCancel,
                imagePath: imagePath,
                type: type,
                customWidget: customWidget,
              ),
            ),
          ),
        );
      },
    );
}