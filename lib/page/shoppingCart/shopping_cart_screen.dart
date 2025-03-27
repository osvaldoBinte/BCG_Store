import 'package:flutter/material.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/common/theme/App_Theme.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  // Sample shopping cart items
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Camisa Casual',
      price: 45.99,
      quantity: 1,
      image: 'https://luberalba.com/wp-content/uploads/2019/01/Marcas_de_ropa_de_hombre.jpg',
    ),
    CartItem(
      id: '2',
      name: 'Pantalón Formal',
      price: 69.99,
      quantity: 1,
      image: 'https://luberalba.com/wp-content/uploads/2019/01/Marcas_de_ropa_de_hombre.jpg',
    ),
    CartItem(
      id: '3',
      name: 'Suéter de Invierno',
      price: 55.50,
      quantity: 1,
      image: 'https://luberalba.com/wp-content/uploads/2019/01/Marcas_de_ropa_de_hombre.jpg',
    ),
  ];

  // Calculate total price
  double get _totalPrice {
    return _cartItems.fold(
        0, (total, item) => total + (item.price * item.quantity));
  }

  void _updateQuantity(String id, int change) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        final newQuantity = _cartItems[index].quantity + change;
        if (newQuantity > 0) {
          _cartItems[index].quantity = newQuantity;
        } else {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.backgroundColor,
          onPressed: () async{  await NavigationService.to.navigateToHome(initialIndex: 0);
          }
        ),
        title: const Text('Carrito de Compras'),
       
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(),
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : _buildCheckoutSection(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppTheme.iconGrey,
          ),
          const SizedBox(height: 20),
          Text(
            'Tu carrito está vacío',
            style: AppTheme.theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Agrega productos para comenzar a comprar',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Ir a la Tienda'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Productos en tu carrito',
              style: AppTheme.theme.textTheme.headlineMedium,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = _cartItems[index];
              return _buildCartItem(item);
            },
            childCount: _cartItems.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de la orden',
                  style: AppTheme.theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildOrderSummaryRow('Subtotal', '\$${_totalPrice.toStringAsFixed(2)}'),
                _buildOrderSummaryRow('Envío', 'Gratis'),
                _buildOrderSummaryRow('Impuestos', '\$${(_totalPrice * 0.16).toStringAsFixed(2)}'),
                const Divider(thickness: 1),
                _buildOrderSummaryRow(
                  'Total',
                  '\$${(_totalPrice + (_totalPrice * 0.16)).toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTheme.theme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () => _updateQuantity(item.id, -1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: AppTheme.fieldValueStyle,
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () => _updateQuantity(item.id, 1),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppTheme.iconGrey,
                        ),
                        onPressed: () => _updateQuantity(item.id, -item.quantity),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundGreyDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildOrderSummaryRow(String title, String value, {bool isBold = false}) {
    final textStyle = isBold
        ? const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )
        : const TextStyle(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textStyle),
          Text(value, style: textStyle),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Proceder al Pago'),
      ),
    );
  }
}

// Model class for cart items
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
}