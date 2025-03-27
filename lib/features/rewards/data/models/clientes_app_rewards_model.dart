import 'package:gerena/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';

class ClientesAppRewardsModel  extends ClientesAppRewardsEntitie{
  ClientesAppRewardsModel({
     int? id,
  required String username,
  required String first_name,
  required String last_name,
  required String email,
  }) : super(
          id: id,
          username: username,
          first_name: first_name,
          last_name: last_name,
          email: email,
        );
  
  factory ClientesAppRewardsModel.fromJson(Map<String, dynamic> json) {
    return ClientesAppRewardsModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      first_name: json['first_name'] ?? '',
      last_name: json['last_name'] ?? '',
      email: json['email'] ?? '',
    );
  }
  factory ClientesAppRewardsModel.fromEntity(ClientesAppRewardsEntitie clientesAppRewardsEntitie) {
    return ClientesAppRewardsModel(
      id: clientesAppRewardsEntitie.id,
      username: clientesAppRewardsEntitie.username,
      first_name: clientesAppRewardsEntitie.first_name,
      last_name: clientesAppRewardsEntitie.last_name,
      email: clientesAppRewardsEntitie.email,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id':
          id,
      'username': username,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
    };  
  }
}