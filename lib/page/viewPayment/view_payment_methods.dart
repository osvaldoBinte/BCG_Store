import 'package:flutter/material.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/page/payment/add_payment_method.dart';
import 'package:gerena/page/viewPayment/payment_methods_controller.dart';
import 'package:get/get.dart';

class ViewPaymentMethodsScreen extends StatelessWidget {
  const ViewPaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PaymentMethodsController controller = Get.put(PaymentMethodsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('MIS MÉTODOS DE PAGO', style: AppTheme.theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tarjetas y métodos de pago registrados',
                style: AppTheme.theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Lista de métodos de pago
            Expanded(
              child: GetBuilder<PaymentMethodsController>(
                builder: (controller) {
                  return controller.hasPaymentMethods 
                      ? _buildPaymentMethodsList(controller) 
                      : _buildEmptyState();
                },
              ),
            ),
            
            // Botón para agregar nuevo método de pago
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => AddPaymentMethodScreen());
                },
                icon: Icon(Icons.add),
                label: Text('AGREGAR NUEVO MÉTODO DE PAGO'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList(PaymentMethodsController controller) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.paymentMethods.length,
      itemBuilder: (context, index) {
        final method = controller.paymentMethods[index];
        return _buildPaymentMethodCard(method, controller);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No tienes métodos de pago registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega una tarjeta para realizar compras más rápido',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    Map<String, dynamic> method, 
    PaymentMethodsController controller
  ) {
    // Determinar el icono de la marca
    IconData brandIcon;
    Color brandColor;
    
    switch(method['brand']) {
      case 'visa':
        brandIcon = Icons.credit_card;
        brandColor = Colors.blue.shade800;
        break;
      case 'mastercard':
        brandIcon = Icons.credit_card;
        brandColor = Colors.deepOrange;
        break;
      case 'amex':
        brandIcon = Icons.credit_card;
        brandColor = Colors.indigo;
        break;
      default:
        brandIcon = Icons.credit_card;
        brandColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: method['isDefault'] 
              ? AppTheme.primaryColor 
              : Colors.grey.shade300,
          width: method['isDefault'] ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Encabezado de la tarjeta con el ícono de marca y tipo de tarjeta
            Row(
              children: [
                Icon(brandIcon, color: brandColor, size: 32),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['brand'].toString().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      method['type'] == 'credit' ? 'Tarjeta de Crédito' : 'Tarjeta de Débito',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                if (method['isDefault'])
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PREDETERMINADA',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Información de la tarjeta
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Número de tarjeta
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Número',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '•••• •••• •••• ${method['last4']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Fecha de expiración
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expira',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        method['expiry'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Titular de la tarjeta
            Row(
              children: [
                Icon(Icons.person, color: AppTheme.textSecondaryColor, size: 16),
                SizedBox(width: 8),
                Text(
                  'Titular: ${method['holder']}',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Lógica para editar - aquí se podría pasar los datos de la tarjeta
                      Get.to(() => AddPaymentMethodScreen());
                    },
                    icon: Icon(Icons.edit, size: 14),
                    label: Text('EDITAR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.showDeleteConfirmationDialog(method['id']);
                    },
                    icon: Icon(Icons.delete, size: 14),
                    label: Text('ELIMINAR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (!method['isDefault']) ...[
                  SizedBox(width: 12),
                 Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.setAsDefault(method['id']);
                      },
                      icon: Icon(Icons.check_circle, size: 14), 
                      label: Text(
                        'PREDETERMINADA',
                        style: TextStyle(fontSize: 10),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 9), 
                        minimumSize: Size(0, 38),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}