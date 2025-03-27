class RegisterEntitie {
  final int id_cliente;
  final String email;
  final String password;
  final String first_name;
  final String last_name;

  RegisterEntitie({
    required this.first_name, 
    required this.last_name, 
    required this.id_cliente,
    required this.email,
    required this.password,
  });
}