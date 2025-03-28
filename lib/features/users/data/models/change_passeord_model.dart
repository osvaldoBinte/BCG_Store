
import 'package:BCG_Store/features/users/domain/entities/change_password_entitie.dart';

class ChangePasseordModel extends ChangePasswordEntitie {
  ChangePasseordModel({
    int? id_cliente,
    required String current_password,
    required String new_password,
    required String confirm_password,
  }) : super(
          id_cliente: id_cliente,
          current_password: current_password,
          new_password: new_password,
          confirm_password: confirm_password,
   
         
        );

  factory ChangePasseordModel.fromJson(Map<String, dynamic> json) {
    return ChangePasseordModel(
      id_cliente: json['id_cliente']??'',
      current_password: json['current_password']??'',
      new_password: json['new_password']??'',
      confirm_password: json['confirm_password']??'',
     
     
    );
  }
  factory ChangePasseordModel.fromEntity(ChangePasswordEntitie changePassword) {
    return ChangePasseordModel(
      id_cliente: changePassword.id_cliente,
      current_password: changePassword.current_password,
      new_password: changePassword.new_password,
      confirm_password: changePassword.confirm_password,
   
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_cliente': id_cliente,
      'current_password': current_password,
      'new_password': new_password,
      'confirm_password': confirm_password,
      
     
    };
  }

}