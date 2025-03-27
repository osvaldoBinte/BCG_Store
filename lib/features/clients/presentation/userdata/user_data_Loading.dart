import 'package:flutter/material.dart';
import 'package:gerena/common/theme/App_Theme.dart';

class UserDataLoading extends StatefulWidget {
  const UserDataLoading({Key? key}) : super(key: key);
  
  @override
  State<UserDataLoading> createState() => _UserDataLoadingState();
}

class _UserDataLoadingState extends State<UserDataLoading>
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
    
    // Crea una animación para el efecto shimmer
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
      backgroundColor: AppTheme.secondaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
      ),
      body: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Column(
            children: [
              // Header skeleton
              Container(
                color: AppTheme.secondaryColor,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: AppBar(
                    primary: false,
                    backgroundColor: AppTheme.secondaryColor,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    leading: _buildShimmerBox(
                      child: const CircleAvatar(
                        backgroundColor: AppTheme.Loading,
                        radius: 16,
                      ),
                    ),
                    title: Column(
                      children: [
                        _buildShimmerBox(
                          child: Container(
                            height: 18,
                            width: 120,
                            decoration: BoxDecoration(
                              color:AppTheme.Loading,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildShimmerBox(
                          child: Container(
                            height: 12,
                            width: 220,
                            decoration: BoxDecoration(
                              color:AppTheme.Loading,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                  ),
                ),
              ),
              
              // Content skeleton
              Expanded(
                child: ListView(
                  children: [
                    // Sección del perfil - Avatar, nombre y email con más detalles
                    Container(
                      color: AppTheme.secondaryColor,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar skeleton con borde y efecto shimmer
                          
                          const SizedBox(width: 16),
                          // Nombre y correo con más detalles
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Placeholder para el nombre
                                _buildShimmerBox(
                                  child: Container(
                                    height: 18,
                                    width: 160,
                                    decoration: BoxDecoration(
                                      color: AppTheme.Loading,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.textSecondaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildShimmerBox(
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:AppTheme.Loading,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildShimmerBox(
                                    child: Container(
                                      height: 14,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.Loading,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Botón Editar
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.textSecondaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildShimmerBox(
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.Loading,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildShimmerBox(
                                    child: Container(
                                      height: 14,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.Loading,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    _buildInfoCardSkeleton(),
                    
                    const SizedBox(height: 16),
                    
                    _buildMenuItemSkeleton(),
                    _buildMenuItemSkeleton(),
                    _buildMenuItemSkeleton(),
                    _buildMenuItemSkeleton(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
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
  
  Widget _buildInfoCardSkeleton() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: _buildShimmerBox(
              child: Container(
                height: 18,
                width: 160,
                decoration: BoxDecoration(
                  color: AppTheme.Loading,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Info items skeletons
          _buildInfoItemSkeleton(),
          _buildInfoItemSkeleton(),
          _buildInfoItemSkeleton(),
          _buildInfoItemSkeleton(),
        ],
      ),
    );
  }
  
  Widget _buildInfoItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color:AppTheme.Loading,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(
                  child: Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.Loading,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _buildShimmerBox(
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.Loading,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildMenuItemSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildShimmerBox(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.Loading,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(
                    child: Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.Loading,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildShimmerBox(
                    child: Container(
                      height: 12,
                      width: 200,
                      decoration: BoxDecoration(
                        color:AppTheme.Loading,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildShimmerBox(
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.Loading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}