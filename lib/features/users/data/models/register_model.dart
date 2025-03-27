import 'package:gerena/features/users/domain/entities/register_entitie.dart';

class RegisterModel extends RegisterEntitie {
  RegisterModel({
    required int id_cliente,
  required String email,
  required String password,
  required String first_name,
  required String last_name,

  }) : super(
          id_cliente: id_cliente,
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name,
         
        );

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      id_cliente: json['id_cliente']??'',
      email: json['email']??'',
      password: json['password']??'',
      first_name: json['first_name']??'',
      last_name: json['last_name']??'',
     
    );
  }
  factory RegisterModel.fromEntity(RegisterEntitie registerEntitie) {
    return RegisterModel(
      id_cliente: registerEntitie.id_cliente,
      email: registerEntitie.email,
      password: registerEntitie.password,
      first_name: registerEntitie.first_name,
      last_name: registerEntitie.last_name,
   
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_cliente': id_cliente,
      'email': email,
      'password': password,
      'first_name': first_name,
      'last_name': last_name,
     
    };
  }

}