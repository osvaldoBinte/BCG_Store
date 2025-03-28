import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';

class PaymentMethodController extends GetxController {
  // Variables para la tarjeta
  final cardNumber = ''.obs;
  final expiryDate = ''.obs;
  final cardHolderName = ''.obs;
  final cvvCode = ''.obs;
  final isCvvFocused = false.obs;
  
  // Variables para opciones
  final isDefaultCard = true.obs;
  final rememberCard = false.obs;
  final selectedCardType = 'credit'.obs;
  
  // Llave del formulario para validación
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Método para actualizar los datos de la tarjeta
  void updateCreditCard(CreditCardModel creditCardModel) {
    cardNumber.value = creditCardModel.cardNumber;
    expiryDate.value = creditCardModel.expiryDate;
    cardHolderName.value = creditCardModel.cardHolderName;
    cvvCode.value = creditCardModel.cvvCode;
    isCvvFocused.value = creditCardModel.isCvvFocused;
  }
  
  // Método para cambiar el tipo de tarjeta seleccionado
  void setCardType(String type) {
    selectedCardType.value = type;
  }
  
  // Método para cambiar el estado de tarjeta predeterminada
  void toggleDefaultCard() {
    isDefaultCard.value = !isDefaultCard.value;
  }
  
  // Método para cambiar el estado de recordar tarjeta
  void toggleRememberCard() {
    rememberCard.value = !rememberCard.value;
  }
  
  // Método para validar y guardar la tarjeta
  bool saveCard() {
    if (formKey.currentState!.validate()) {
      // Aquí iría la lógica para guardar la tarjeta en la base de datos
      // o enviarla a un servidor
      return true;
    }
    return false;
  }
  
  // Método para mostrar el diálogo de éxito
  void showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Tarjeta agregada!',
              style: AppTheme.theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Tu tarjeta ha sido agregada exitosamente a tus métodos de pago.',
          style: AppTheme.theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('ACEPTAR'),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}