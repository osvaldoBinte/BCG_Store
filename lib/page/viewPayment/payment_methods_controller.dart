import 'package:flutter/material.dart';
import 'package:BCG_Store/common/widgets/custom_alert_type.dart';
import 'package:get/get.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';

class PaymentMethodsController extends GetxController {
  final paymentMethods = <Map<String, dynamic>>[
    {
      'id': '1',
      'type': 'credit',
      'brand': 'visa',
      'last4': '4242',
      'expiry': '03/28',
      'holder': 'Juan Pérez',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'credit',
      'brand': 'mastercard',
      'last4': '5678',
      'expiry': '12/26',
      'holder': 'Juan Pérez',
      'isDefault': false,
    },
    {
      'id': '3',
      'type': 'debit',
      'brand': 'visa',
      'last4': '9012',
      'expiry': '08/27',
      'holder': 'Juan Pérez',
      'isDefault': false,
    },
  ].obs;

  bool get hasPaymentMethods => paymentMethods.isNotEmpty;

  Map<String, dynamic>? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((method) => method['isDefault'] == true);
    } catch (e) {
      return null;
    }
  }

  void addPaymentMethod(Map<String, dynamic> method) {
    // Si es el primer método, establecerlo como predeterminado
    if (paymentMethods.isEmpty) {
      method['isDefault'] = true;
    } else {
      method['isDefault'] = false;
    }
    paymentMethods.add(method);
    update(); 
  }

  void deletePaymentMethod(String id) {
    bool wasDefault = false;
    Map<String, dynamic>? methodToRemove;
    
    for (var method in paymentMethods) {
      if (method['id'] == id) {
        wasDefault = method['isDefault'] == true;
        methodToRemove = method;
        break;
      }
    }
    
    if (methodToRemove != null) {
      paymentMethods.remove(methodToRemove);
      
      if (wasDefault && paymentMethods.isNotEmpty) {
        paymentMethods[0]['isDefault'] = true;
      }
      
      update(); 
    }
  }

  void setAsDefault(String id) {
    for (var method in paymentMethods) {
      method['isDefault'] = false;
    }
    
    for (var method in paymentMethods) {
      if (method['id'] == id) {
        method['isDefault'] = true;
        break;
      }
    }
    
    update(); 
  }

  void editPaymentMethod(String id, Map<String, dynamic> updatedData) {
    for (int i = 0; i < paymentMethods.length; i++) {
      if (paymentMethods[i]['id'] == id) {
        bool wasDefault = paymentMethods[i]['isDefault'] == true;
        updatedData['isDefault'] = wasDefault;
        
        paymentMethods[i] = updatedData;
        break;
      }
    }
    
    update(); 
  }

    void showDeleteConfirmationDialog(String id) {
    Map<String, dynamic>? method;
    for (var m in paymentMethods) {
      if (m['id'] == id) {
        method = m;
        break;
      }
    }
    
    if (method == null) return;
    
    showCustomAlert(
      context: Get.context!,
      title: '¿Eliminar método de pago?',
      message: '¿Estás seguro de que deseas eliminar la tarjeta terminada en ${method['last4']}?',
      confirmText: 'Cancelar',
      cancelText: 'Eliminar',
      type: CustomAlertType.error, 
      onConfirm: () {
        Navigator.of(Get.context!).pop();
      },
      onCancel: () {
        deletePaymentMethod(id);
        Navigator.of(Get.context!).pop();
        Get.snackbar(
          'Método de pago eliminado',
          'El método de pago ha sido eliminado exitosamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          margin: EdgeInsets.all(8),
        );
      },
    );

  }
}