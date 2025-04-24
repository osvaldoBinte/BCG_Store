class ClientesAppRewardsEntitie {
   int? id;
  final String username;
  final String first_name;
  final String last_name;
  final String email;
  final String? token_device;
  ClientesAppRewardsEntitie({
     this.id,
    required this.username,
    required this.first_name,
    required this.last_name,
    required this.email,
    this.token_device,
  });
}