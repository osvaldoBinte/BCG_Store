import 'package:gerena/features/users/data/models/login_response.dart';
import 'package:gerena/features/users/domain/entities/change_password_entitie.dart';
import 'package:gerena/features/users/domain/entities/register_entitie.dart';

abstract class UserRepository {
  
  Future registerUser(RegisterEntitie registerEntitie);
  Future<LoginResponse> loginUser(String username, String password, [String? base_datos]);
  Future changePassword(ChangePasswordEntitie change_password_entitie);
}
