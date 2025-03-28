import 'package:BCG_Store/features/users/data/models/login_response.dart';
import 'package:BCG_Store/features/users/domain/entities/change_password_entitie.dart';
import 'package:BCG_Store/features/users/domain/entities/register_entitie.dart';

abstract class UserRepository {
  
  Future registerUser(RegisterEntitie registerEntitie);
  Future<LoginResponse> loginUser(String username, String password, [String? base_datos]);
  Future changePassword(ChangePasswordEntitie change_password_entitie);
  Future<void> recoveryPassword(String email);
}
