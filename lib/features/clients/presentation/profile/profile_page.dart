import 'package:flutter/material.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/common/services/auth_service.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/features/clients/presentation/profile/profile_controller.dart';
import 'package:gerena/page/payment/add_payment_method.dart';
import 'package:gerena/page/viewPayment/view_payment_methods.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final RxBool _isTiendaActiva = true.obs;
        final authService = AuthService();

final RxInt _currentPage = 0.obs;
  @override
  void initState() {
    super.initState();
    _checkTiendaStatus();
  }

  Future<void> _checkTiendaStatus() async {
    try {
      final session = await authService.getSession();
      if (session != null) {
        _isTiendaActiva.value = session.tienda_activa == "1";
        print('✅ Estado de la tienda: ${_isTiendaActiva.value ? "Activa" : "Inactiva"}');
      } else {
        _isTiendaActiva.value = false;
        print('❌ No hay sesión activa');
      }
    } catch (e) {
      print('❌ Error al verificar el estado de la tienda: $e');
      _isTiendaActiva.value = false;
    }
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppTheme.theme.iconTheme.size,
              color: AppTheme.theme.iconTheme.color,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTheme.theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star,
              color: AppTheme.secondaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus Puntos',
                  style: AppTheme.theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Encuentra maneras de ganar más',
                  style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildAddPaymentMethodCard(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => AddPaymentMethodScreen()),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.addPaymen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_card,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agregar Pago',
                    style: AppTheme.theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Añade métodos de pago',
                    style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: TextButton(
                onPressed: () => Get.to(() => AddPaymentMethodScreen()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(50, 30),
                ),
                child: const Text(
                  'Agregar',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewPaymentMethodsCard(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => ViewPaymentMethodsScreen()),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.ViewPaymen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payment,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Métodos de Pago',
                    style: AppTheme.theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Administra tus tarjetas',
                    style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(50, 30),
                ),
                child: const Text(
                  'Ver',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildCardsCarousel(BuildContext context) {
  return Obx(() {
    List<Widget> cards = [_buildPointsCard(context)];
    
    if (_isTiendaActiva.value) {
      cards.add(_buildAddPaymentMethodCard(context));
      cards.add(_buildViewPaymentMethodsCard(context));
    }
    
    return SizedBox(
      height: 180, 
      child: ListView.builder(
        itemCount: cards.length,
        scrollDirection: Axis.horizontal,
        physics: PageScrollPhysics(),
        itemBuilder: (context, index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == _currentPage.value) {
            }
          });
          
          return Container(
            width: MediaQuery.of(context).size.width - 32,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: cards[index],
          );
        },
        controller: ScrollController()
          ..addListener(() {
            
            if (_currentPage.value != (cards.length / 2).round()) {
              _currentPage.value = (cards.length / 2).round();
            }
          }),
      ),
    );
  });
}
  Widget _buildPageIndicator(int totalPages, int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.theme.iconTheme.color,
        ),
        title: Text(
          text,
          style: AppTheme.theme.textTheme.bodyLarge,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.theme.iconTheme.color,
        ),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final ProfileController controller = Get.find<ProfileController>();
    
    // Determinar la altura de la barra de navegación inferior
    final bottomNavHeight = 70.0 + 16.0 * 2; // NavBar height + margins

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calcular el espacio disponible real
          final availableHeight = constraints.maxHeight;
          
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomNavHeight),
            child: ConstrainedBox(
              // Restricción para asegurar que el contenido ocupe al menos toda la pantalla visible
              constraints: BoxConstraints(
                minHeight: availableHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppTheme.primaryColor,
                    padding: EdgeInsets.fromLTRB(20, padding.top, 20, 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        const SizedBox(height: 16),
                        Text(
                          'Utilízalo en nuestras tiendas para agilizar tus compras, devoluciones y disfrutar beneficios exclusivos.',
                          style: AppTheme.theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuButton(
                                context,
                                Icons.shopping_bag_outlined,
                                'Mis Compras',
                                onTap: () async {
                                  await NavigationService.to.navigateToPurchases();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMenuButton(
                                context,
                                Icons.star_border,
                                'Mis Puntos',
                                onTap: () async {
                                  await NavigationService.to.navigateToPoints();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuButton(
                                context,
                                Icons.qr_code,
                                'Mi QR',
                                onTap: () => controller.showQRModal(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMenuButton(
                                context,
                                Icons.person,
                                'Mi Cuenta',
                                onTap: () async {
                                  await NavigationService.to.navigateToUserData();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Título para el carrusel
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 12),
                          child: Text(
                            'Servicios',
                            style: AppTheme.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Carrusel horizontal de tarjetas - Condicional según estado de tienda
                        _buildCardsCarousel(context),
                        
                        // Indicadores de página para el carrusel - Adaptado al número de tarjetas
                        Obx(() {
                            int totalPages = _isTiendaActiva.value ? 3 : 1;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildPageIndicator(totalPages, _currentPage.value),
                            );
                          }),
                        
                        const SizedBox(height: 24),
                      
                        const SizedBox(height: 24),
                      
                        // Espacio adicional al final para asegurar que la NavBar no tape el contenido
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}