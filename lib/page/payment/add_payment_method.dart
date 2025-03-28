import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/page/payment/payment_method_controller.dart';
import 'package:get/get.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador
    final PaymentMethodController controller = Get.put(PaymentMethodController());

    return Scaffold(
      appBar: AppBar(
        title: Text('AGREGAR MÉTODO DE PAGO', style: AppTheme.theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Tarjeta de crédito
              Obx(() => CreditCardWidget(
                cardNumber: controller.cardNumber.value,
                expiryDate: controller.expiryDate.value,
                cardHolderName: controller.cardHolderName.value,
                cvvCode: controller.cvvCode.value,
                showBackView: controller.isCvvFocused.value,
                obscureCardNumber: true,
                obscureCardCvv: true,
                isHolderNameVisible: true,
                cardBgColor: AppTheme.primaryColor,
                isSwipeGestureEnabled: true,
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                customCardTypeIcons: <CustomCardTypeIcon>[
                  CustomCardTypeIcon(
                    cardType: CardType.mastercard,
                    cardImage: Image.asset(
                      'assets/mastercard.png',
                      height: 48,
                      width: 48,
                    ),
                  ),
                ],
              )),
              
              // Formulario de tarjeta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Theme(
                      // Aplicamos un tema personalizado para darle el estilo que queremos
                      data: Theme.of(context).copyWith(
                        primaryColor: AppTheme.primaryColor,
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppTheme.primaryColor,
                        ),
                        inputDecorationTheme: InputDecorationTheme(
                          labelStyle: AppTheme.fieldLabelStyle,
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIconColor: AppTheme.primaryColor,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      child: CreditCardForm(
                        formKey: controller.formKey,
                        cardNumber: controller.cardNumber.value,
                        expiryDate: controller.expiryDate.value,
                        cardHolderName: controller.cardHolderName.value,
                        cvvCode: controller.cvvCode.value,
                        obscureCvv: true,
                        obscureNumber: true,
                        isHolderNameVisible: true,
                        isCardNumberVisible: true,
                        isExpiryDateVisible: true,
                        enableCvv: true,
                        cvvValidationMessage: 'Por favor ingresa un CVV válido',
                        dateValidationMessage: 'Por favor ingresa una fecha válida',
                        numberValidationMessage: 'Por favor ingresa un número válido',
                        onCreditCardModelChange: controller.updateCreditCard,
                        // Estos campos no están en la versión 4.1.0, así que los removemos
                        // y agregamos decoraciones personalizadas usando prefijos en el Theme
                        cardHolderValidator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return 'Por favor ingresa el nombre del titular';
                          }
                          return null;
                        },
                        // Los decoradores se aplican automáticamente por el tema
                      ),
                    ),
                  ),
                ),
              ),
              
              // Selección de tipo de tarjeta
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIPO DE TARJETA',
                      style: AppTheme.theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Obx(() => _buildCardTypeOption(
                          'Crédito', 
                          Icons.credit_card, 
                          controller.selectedCardType.value == 'credit',
                          () => controller.setCardType('credit'),
                        )),
                        Obx(() => _buildCardTypeOption(
                          'Débito', 
                          Icons.credit_score, 
                          controller.selectedCardType.value == 'debit',
                          () => controller.setCardType('debit'),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Opciones adicionales
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Obx(() => _buildOptionTile(
                      'Guardar como método predeterminado',
                      'Esta tarjeta se usará para futuros pagos',
                      controller.isDefaultCard.value,
                      controller.toggleDefaultCard,
                    )),
                    const SizedBox(height: 8),
                    Obx(() => _buildOptionTile(
                      'Recordar mi tarjeta',
                      'Guardar de forma segura para compras rápidas',
                      controller.rememberCard.value,
                      controller.toggleRememberCard,
                    )),
                  ],
                ),
              ),
              
              // Botón para guardar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.saveCard()) {
                        controller.showSuccessDialog();
                      }
                    },
                    child: const Text('GUARDAR TARJETA'),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              // Información de seguridad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Tus datos están protegidos con encriptación SSL',
                      style: AppTheme.theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeOption(String title, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? AppTheme.primaryColor : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String subtitle, bool value, VoidCallback onToggle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}