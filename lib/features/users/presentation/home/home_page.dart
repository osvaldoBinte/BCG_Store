import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BCG_Store/common/services/auth_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/clients/presentation/profile/profile_page.dart';
import 'package:BCG_Store/page/store/store.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  final int initialIndex;
  
  HomePage({Key? key, required this.initialIndex}) : super(key: key);

  final RxBool _isTiendaActiva = true.obs;

  final List<Widget> _pages = [
    StorePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    _checkTiendaStatus();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(), 
      ),
      body: SafeArea( 
        child: Stack(
          fit: StackFit.expand, 
          children: [
            Positioned.fill(  
              child: Obx(() {
                if (!_isTiendaActiva.value) {
                  if (controller.selectedIndex.value == 0) {
                    controller.setIndex(1);
                  }
                  return ProfilePage();
                }
                
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.5, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _pages[controller.selectedIndex.value],
                );
              }),
            ),
            Obx(() => _isTiendaActiva.value ? _buildNavBar(context) : const SizedBox()),
          ],
        ),
      ),  
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.theme.colorScheme.primary, 
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: AppTheme.dividerColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: controller.selectedIndex.value == 0 
                  ? (MediaQuery.of(context).size.width - 32) / 4 - 30
                  : 3 * (MediaQuery.of(context).size.width - 32) / 4 - 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.theme.colorScheme.secondary,
                ),
              ),
            )),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => controller.setIndex(0),
                    child: _buildNavIcon(context, Icons.shopping_bag, 0),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => controller.setIndex(1),
                    child: _buildNavIcon(context, Icons.person, 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, int index) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      
      return SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.8),
              child: Icon(
                icon,
                size: 30,
                color: isSelected
                    ? AppTheme.theme.colorScheme.primary 
                    : AppTheme.theme.colorScheme.secondary, 
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _checkTiendaStatus() async {
    try {
      final authService = AuthService();
      final session = await authService.getSession();
      
      if (session != null) {
        final tiendaStatus = session.tienda_activa == "1";
        _isTiendaActiva.value = tiendaStatus;
        
        print('✅ Estado de la tienda: ${tiendaStatus ? "Activa" : "Inactiva"}');
        
    
        if (!tiendaStatus && controller.selectedIndex.value == 0) {
          controller.setIndex(1);
        }
      } else {
        _isTiendaActiva.value = false;
        print('❌ No hay sesión activa');
      }
    } catch (e) {
      print('❌ Error al verificar el estado de la tienda: $e');
      _isTiendaActiva.value = false;
    }
  }
}