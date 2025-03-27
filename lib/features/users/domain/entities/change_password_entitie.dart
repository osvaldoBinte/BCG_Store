class ChangePasswordEntitie {
  int? id_cliente;
  final String current_password;
  final String new_password;
  final String confirm_password;

  ChangePasswordEntitie({
    this.id_cliente,
    required this.current_password,
    required this.new_password,
    required this.confirm_password,
  });
}