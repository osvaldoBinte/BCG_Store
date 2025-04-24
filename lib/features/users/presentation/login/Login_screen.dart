import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:BCG_Store/common/services/theme_service.dart';
import 'package:BCG_Store/common/widgets/rounded_logo_widget.dart';
import 'package:BCG_Store/features/users/presentation/login/login_controller.dart';
import 'package:BCG_Store/features/users/presentation/login/qr_scanner_widget.dart';
import 'package:get/get.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final LoginController controller = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppTheme.primaryColor, 
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenedor superior con animación
           // En tu LoginScreen
GetX<LoginController>(
  builder: (_) {
    // Calcular la altura del contenedor basado en el estado actual
    final containerHeight = (controller.isLoginForm.value || 
              controller.isRegisterForm.value || 
              controller.isQrScannerVisible.value ||
              controller.isRecoveryForm.value ||
              controller.isTempPasswordForm.value ||
              controller.isChangePasswordForm.value)
        ? screenSize.height * 0.25  
        : screenSize.height * 0.35;
        
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            final url = ThemeService.to.logoUrl.value.isNotEmpty
                ? ThemeService.to.logoUrl.value
                : AppTheme.defaultLogoAsset;
                
            // Calcular el tamaño del logo como un porcentaje de la altura del contenedor
            final logoHeight = containerHeight * 0.6; // 60% de la altura del contenedor
                
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: RoundedLogoWidget(
                  height: logoHeight,
                  width: screenSize.width * 0.6,
                  borderRadius: 8.0,
                  fit: BoxFit.contain, 
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
),
            
            // Contenido inferior
            Expanded(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: GetX<LoginController>(
                    builder: (_) {
                      if (controller.isLoginForm.value) {
                        return _buildLoginForm(theme);
                      } else if (controller.isRegisterForm.value) {
                        return _buildRegisterForm(theme);
                      } else if (controller.isQrScannerVisible.value) {
                        return QRScannerWidget();
                      } else if (controller.isRecoveryForm.value) {
                        return _buildRecoveryForm(theme);
                      } else if (controller.isTempPasswordForm.value) {
                        return _buildTempPasswordForm(theme);
                      } else if (controller.isChangePasswordForm.value) {
                        return _buildChangePasswordForm(theme);
                      } else {
                        return _buildInitialContent(theme);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      key: const ValueKey('login_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'INICIAR SESIÓN',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Campo de entrada para correo electrónico (que será enviado como username)
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico', 
            prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
            hintText: 'ejemplo@correo.com',
          ),
          keyboardType: TextInputType.emailAddress, 
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).requestFocus(controller.passwordFocusNode);
          },
        ),
        const SizedBox(height: 16),
        
        Obx(() => TextField(
          controller: controller.passwordController,
          focusNode: controller.passwordFocusNode,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value 
                  ? Icons.visibility_off 
                  : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
              },
            ),
          ),
          obscureText: !controller.isPasswordVisible.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.login(),
        )),
        const SizedBox(height: 32),
        
        Obx(() => 
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            style: theme.elevatedButtonTheme.style,
            child: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                 child: SpinKitHourGlass(
                    color: AppTheme.primaryColor,
                    size: 30.0,
                  ),
                )
              : Text('INICIAR SESIÓN'),
          )
        ),
        
        const SizedBox(height: 16),
        
        Obx(() {
          final baseDatos = controller.qrClientData.value['base_datos'];
          if (baseDatos == null || baseDatos.toString().isEmpty) {
            return OutlinedButton.icon(
              onPressed: controller.showQRScannerForLogin,
              icon: Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
              label: Text('Escanear código QR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
              ),
            );
          }
          return SizedBox.shrink();
        }),
        
        const SizedBox(height: 16),
        
        // Botón para recuperar contraseña
        TextButton(
          onPressed: controller.toggleRecoveryForm,
          child: Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextButton(
          onPressed: () {
            // Volver a la pantalla inicial
            controller.isLoginForm.value = false;
          },
          child: Text(
            'Volver',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
  Widget _buildRecoveryForm(ThemeData theme) {
    return Column(
      key: const ValueKey('recovery_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'RECUPERAR CONTRASEÑA',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Ingresa tu correo electrónico para recibir instrucciones de recuperación.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Campo de correo electrónico para recuperación
        TextField(
          controller: controller.recoveryEmailController,
          focusNode: controller.recoveryEmailFocusNode,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
            hintText: 'ejemplo@correo.com',
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.recoverPassword(),
        ),
        
        const SizedBox(height: 32),
        
        // Botón para enviar solicitud de recuperación
        Obx(() => 
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.recoverPassword,
            style: theme.elevatedButtonTheme.style,
            child: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: SpinKitHourGlass(
                    color: AppTheme.primaryColor,
                    size: 30.0,
                  ),
                )
              : Text('RECUPERAR CONTRASEÑA'),
          )
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: controller.toggleLoginForm,
          child: Text(
            'Volver a Iniciar Sesión',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
  Widget _buildTempPasswordForm(ThemeData theme) {
    return Column(
      key: const ValueKey('temp_password_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'INGRESAR CONTRASEÑA TEMPORAL',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Por favor ingresa la contraseña temporal que recibiste en tu correo electrónico.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Campo para contraseña temporal
        Obx(() => TextField(
          controller: controller.tempPasswordController,
          focusNode: controller.tempPasswordFocusNode,
          decoration: InputDecoration(
            labelText: 'Contraseña Temporal',
            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isTempPasswordVisible.value 
                  ? Icons.visibility_off 
                  : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                controller.isTempPasswordVisible.value = !controller.isTempPasswordVisible.value;
              },
            ),
          ),
          obscureText: !controller.isTempPasswordVisible.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.loginWithTempPassword(),
        )),
        
        const SizedBox(height: 32),
        
        // Botón para continuar con la contraseña temporal
        Obx(() => 
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.loginWithTempPassword,
            style: theme.elevatedButtonTheme.style,
            child: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: SpinKitHourGlass(
                    color: AppTheme.primaryColor,
                    size: 30.0,
                  ),
                )
              : Text('CONTINUAR'),
          )
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: controller.toggleLoginForm,
          child: Text(
            'Volver a Iniciar Sesión',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
  Widget _buildChangePasswordForm(ThemeData theme) {
    return Column(
      key: const ValueKey('change_password_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CAMBIAR CONTRASEÑA',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Por favor establece una nueva contraseña para tu cuenta.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Campo para la contraseña actual (temporal)
        Obx(() => TextField(
          controller: controller.currentPasswordController,
          focusNode: controller.currentPasswordFocusNode,
          decoration: InputDecoration(
            labelText: 'Contraseña Actual (recibida por correo)',
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isCurrentPasswordVisible.value 
                  ? Icons.visibility_off 
                  : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                controller.isCurrentPasswordVisible.value = !controller.isCurrentPasswordVisible.value;
              },
            ),
          ),
          obscureText: !controller.isCurrentPasswordVisible.value,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).requestFocus(controller.newPasswordFocusNode);
          },
        )),
        
        const SizedBox(height: 16),
        
        // Campo para la nueva contraseña
        Obx(() => TextField(
          controller: controller.newPasswordController,
          focusNode: controller.newPasswordFocusNode,
          decoration: InputDecoration(
            labelText: 'Nueva Contraseña',
            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isNewPasswordVisible.value 
                  ? Icons.visibility_off 
                  : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                controller.isNewPasswordVisible.value = !controller.isNewPasswordVisible.value;
              },
            ),
          ),
          obscureText: !controller.isNewPasswordVisible.value,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).requestFocus(controller.confirmPasswordFocusNode);
          },
        )),
        
        const SizedBox(height: 16),
        
        // Campo para confirmar la nueva contraseña
        Obx(() => TextField(
          controller: controller.confirmPasswordController,
          focusNode: controller.confirmPasswordFocusNode,
          decoration: InputDecoration(
            labelText: 'Confirmar Nueva Contraseña',
            prefixIcon: Icon(Icons.lock_clock, color: AppTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordVisible.value 
                  ? Icons.visibility_off 
                  : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                controller.isConfirmPasswordVisible.value = !controller.isConfirmPasswordVisible.value;
              },
            ),
          ),
          obscureText: !controller.isConfirmPasswordVisible.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.changePassword(),
        )),
        
        const SizedBox(height: 32),
        
        // Botón para cambiar contraseña
        Obx(() => 
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.changePassword,
            style: theme.elevatedButtonTheme.style,
            child: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: SpinKitHourGlass(
                    color: AppTheme.primaryColor,
                    size: 30.0,
                  ),
                )
              : Text('CAMBIAR CONTRASEÑA'),
          )
        ),
      ],
    );
  }
  Widget _buildRegisterForm(ThemeData theme) {
    return Column(
      key: const ValueKey('register_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'REGISTRO',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Mostrar información del cliente escaneado con logo
        GetX<LoginController>(
          builder: (_) {
            if (controller.qrClientData.value.isNotEmpty) {
              return Column(
                children: [
                  _buildClientInfoCard(theme),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
        
        const SizedBox(height: 24),
        
        // Campos del formulario
        TextField(
          controller: controller.firstNameController,
          decoration: InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).requestFocus(controller.lastNameFocusNode);
          },
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: controller.lastNameController,
          focusNode: controller.lastNameFocusNode,
          decoration: InputDecoration(
            labelText: 'Apellido',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).requestFocus(controller.emailRegisterFocusNode);
          },
        ),
        const SizedBox(height: 16),
        
        // Campo de correo electrónico (ya no usamos username)
        TextField(
          controller: controller.emailRegisterController,
          focusNode: controller.emailRegisterFocusNode,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
            hintText: 'ejemplo@correo.com',
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).requestFocus(controller.registerPasswordFocusNode);
          },
        ),
        const SizedBox(height: 16),
        
        Obx(() => TextField(
          controller: controller.registerPasswordController,
          focusNode: controller.registerPasswordFocusNode,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isRegisterPasswordVisible.value 
                  ? Icons.visibility_off 
                  : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                controller.isRegisterPasswordVisible.value = !controller.isRegisterPasswordVisible.value;
              },
            ),
          ),
          obscureText: !controller.isRegisterPasswordVisible.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.register(),
        )),
        const SizedBox(height: 32),
        
        // Botón de registro con indicador de carga
        Obx(() => 
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.register,
            style: theme.elevatedButtonTheme.style,
            child: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                 child: SpinKitHourGlass(
                    color: AppTheme.primaryColor,
                    size: 30.0,
                  ),
                )
              : Text('REGISTRARSE'),
          )
        ),
        
        const SizedBox(height: 16),
        // Botón para volver a escanear QR
        OutlinedButton.icon(
          onPressed: controller.toggleRegisterForm,
          icon: Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
          label: Text('Volver a escanear QR'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Volver a la pantalla inicial
            controller.isRegisterForm.value = false;
          },
          child: Text(
            'Volver',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
  Widget _buildClientInfoCard(ThemeData theme) {
    final clientData = controller.qrClientData.value;
    
    return Card(
      elevation: 2,
      color: AppTheme.secondaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
      ),
      
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textTertiaryColor,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInitialContent(ThemeData theme) {
    return Column(
      key: const ValueKey('initial_content'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'DISFRUTA LA MEJOR EXPERIENCIA',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Identifícate para disfrutar de una experiencia personalizada y acceder a todos nuestros servicios.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: controller.toggleLoginForm,
          style: theme.elevatedButtonTheme.style,
          child: Text(
            'INICIAR SESIÓN',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 16,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        Text(
          'Ó',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        
        OutlinedButton(
          onPressed: controller.toggleRegisterForm,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.buttonColor,
            side: BorderSide(color: AppTheme.buttonColor),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ).copyWith(
            textStyle: MaterialStateProperty.all(
              theme.textTheme.labelLarge?.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          child: const Text('REGÍSTRATE'),
        ),
      ],
    );
  }
}