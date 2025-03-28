import 'package:flutter/material.dart';
import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/page/widgets/custom_alert_type.dart';

class StorePage extends StatelessWidget {
  const StorePage({Key? key}) : super(key: key);

Widget _buildHeader(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final padding = MediaQuery.of(context).padding;
  final isSmallScreen = screenSize.width < 360;
  
  return Container(
    width: double.infinity,
    constraints: BoxConstraints(
      minHeight: isSmallScreen ? 160 : 180,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppTheme.primaryColor,
          AppTheme.primaryColor.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    margin: EdgeInsets.only(
      top: isSmallScreen ? 12 : 16,
      left: isSmallScreen ? 12 : 16,
      right: isSmallScreen ? 12 : 16,
      bottom: 8,
    ),
    child: Stack(
      children: [
        Positioned(
          right: 0,
          bottom: 0,
          top: 0,
          width: isSmallScreen ? screenSize.width * 0.4 : 200,
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            child: Image.asset(
              'assets/anuncio.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: isSmallScreen ? screenSize.width * 0.4 + 8 : 208,
            top: 16,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: isSmallScreen ? 24 : 30,
                child: Image.network(
  AppTheme.logoUrl.isNotEmpty
      ? AppTheme.logoUrl
      : AppTheme.defaultLogoAsset,
  height: 160, // Aumenté la altura
  width: 300,  // Aumenté la anchura
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return Image.network(
      AppTheme.defaultLogoAsset,
      height: 160, // Aumenté la altura
      width: 300,  // Aumenté la anchura
      fit: BoxFit.contain,
    );
  },
),

              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Bienvenido,',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 20 : 24,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Claudia Alves!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '👋',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Positioned(
          top: 14,
          right: 14,
          child: GestureDetector(
            onTap: () {
              NavigationService.to.navigateToShoppingCart();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppTheme.secondaryColor,
                    size: 26,
                  ),
                  
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.pointsColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Center(
                        child: Text(
                          '3', 
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildTabs(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTab(context, 'Recomendado', true),
          _buildTab(context, 'Promociones', false),
          _buildTab(context, 'Top', false),
          _buildTab(context, 'Rating', false),

        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

 Widget _buildProductGrid(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavBarHeight = 70.0;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: EdgeInsets.fromLTRB(
        16, 
        16, 
        16, 
        16 + bottomPadding + bottomNavBarHeight, 
      ),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: List.generate(
        8,
        (index) => _buildProductCard(
          context,
          'Liporase',
          'X90 Series',
          200,
          5,
          'https://marketing4ecommerce.net/wp-content/uploads/2024/02/Amazon.jpg'
        ),
      ),
    );
  }


  Widget _buildProductCard(BuildContext context, String name, String series, int price, int rating, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      series,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$$price',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        ...List.generate(
                          rating,
                          (index) => Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
            Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: () {
              _showCartAlert(context, name, price);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_cart,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  

void _showCartAlert(BuildContext context, String productName, int price) {
  showCustomAlert(
    context: context,
    title: '¡Producto Agregado!',
    message: '$productName ha sido agregado a tu carrito de compras.',
    confirmText: 'Seguir Comprando',
    cancelText: 'Ir al Carrito',
    type: CustomAlertType.warning,
    onConfirm: () {
      Navigator.of(context).pop();
    },
    onCancel: () {
              NavigationService.to.navigateToShoppingCart();
      print('Navegando al carrito...');
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildHeader(context),
          _buildTabs(context),
          _buildProductGrid(context),
        ],
      ),
    );
  }
}