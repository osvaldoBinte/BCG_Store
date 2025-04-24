import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';

class PointsLoading extends StatefulWidget {
  const PointsLoading({Key? key}) : super(key: key);
  
  @override
  State<PointsLoading> createState() => _PointsLoadingState();
}

class _PointsLoadingState extends State<PointsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: false);
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      body: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Column(
            children: [
              _buildHeaderSectionSkeleton(),
              
              Expanded(
                child: _buildPointsListSkeleton(context),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildShimmerBox({required Widget child}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _shimmerAnimation.value - 1,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
  
  Widget _buildHeaderSectionSkeleton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 10, bottom: 30, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShimmerBox(
            child: Container(
              height: 48,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsListSkeleton(BuildContext context) {
    // Crear tarjetas esqueleto para un flujo realista de carga
    // Simulamos tener 3 transacciones: 
    // 1. Un punto ganado y expandido (reciente)
    // 2. Un punto usado
    // 3. Otro punto ganado
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Primera tarjeta - Punto ganado - Expandida (la más reciente)
        _buildEarnedPointCardSkeleton(isExpanded: true),
        
        // Segunda tarjeta - Punto usado (no expandida)
        _buildUsedPointCardSkeleton(isExpanded: false),
        
        // Tercera tarjeta - Otro punto ganado (no expandida)
        _buildEarnedPointCardSkeleton(isExpanded: false),
      ],
    );
  }
  
  // Tarjeta de puntos ganados
  Widget _buildEarnedPointCardSkeleton({required bool isExpanded}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Parte superior - siempre visible
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono circular verde
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF0D8067).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: Color(0xFF0D8067).withOpacity(0.3),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                
                // Columna con información (skeleton)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        child: Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildShimmerBox(
                        child: Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildShimmerBox(
                        child: Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icono de flecha
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
          ),
          
          // Detalles expandidos (solo si isExpanded es true)
          if (isExpanded) _buildEarnedDetailsSkeleton(),
        ],
      ),
    );
  }
  
  // Tarjeta de puntos usados
  Widget _buildUsedPointCardSkeleton({required bool isExpanded}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Parte superior - siempre visible
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono circular rojo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.red.withOpacity(0.3),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                
                // Columna con información (skeleton)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        child: Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildShimmerBox(
                        child: Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildShimmerBox(
                        child: Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icono de flecha
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
          ),
          
          // Detalles expandidos (solo si isExpanded es true)
          if (isExpanded) _buildUsedDetailsSkeleton(),
        ],
      ),
    );
  }
  
  // Detalles expandidos para puntos ganados
  Widget _buildEarnedDetailsSkeleton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          _buildShimmerBox(
            child: Container(
              height: 15,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Fecha
          _buildDetailRowSkeleton(),
          SizedBox(height: 8),
          
          // Folio de venta (en contenedor)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildDetailRowSkeleton(),
          ),
        ],
      ),
    );
  }
  
  // Detalles expandidos para puntos usados
  Widget _buildUsedDetailsSkeleton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          _buildShimmerBox(
            child: Container(
              height: 15,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Fecha
          _buildDetailRowSkeleton(),
          SizedBox(height: 8),
          
          // Folio de venta (en contenedor)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildDetailRowSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShimmerBox(
          child: Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        _buildShimmerBox(
          child: Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}