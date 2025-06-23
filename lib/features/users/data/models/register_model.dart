
import 'package:BCG_Store/features/users/domain/entities/register_entitie.dart';

class RegisterModel extends RegisterEntitie {
  RegisterModel({
    required int id_cliente,
  required String email,
  required String password,
  required String first_name,
  required String last_name,
  required String? token_device,
  required String? base_datos,
  }) : super(
          id_cliente: id_cliente,
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name,
          token_device: token_device,
          base_datos: base_datos,
        );
 


  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      id_cliente: json['id_cliente']??'',
      email: json['email']??'',
      password: json['password']??'',
      first_name: json['first_name']??'',
      last_name: json['last_name']??'',
      token_device: json['token_device']??'',
      base_datos: json['base_datos']??'',
     
    );
  }
  factory RegisterModel.fromEntity(RegisterEntitie registerEntitie) {
    return RegisterModel(
      id_cliente: registerEntitie.id_cliente,
      email: registerEntitie.email,
      password: registerEntitie.password,
      first_name: registerEntitie.first_name,
      last_name: registerEntitie.last_name,
      token_device: registerEntitie.token_device,
      base_datos: registerEntitie.base_datos,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_cliente': id_cliente,
      'email': email,
      'password': password,
      'first_name': first_name,
      'last_name': last_name,
     'token_device': token_device,
      'base_datos': base_datos,
    };
  }

}