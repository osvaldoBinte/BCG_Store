import 'package:gerena/common/services/auth_service.dart';
import 'package:gerena/features/users/data/datasources/user_local_data_sources.dart';
import 'package:gerena/features/users/data/models/login_response.dart';
import 'package:gerena/features/users/domain/entities/change_password_entitie.dart';
import 'package:gerena/features/users/domain/entities/register_entitie.dart';
import 'package:gerena/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSources userLocalDataSources;
      final AuthService authService = AuthService();

  UserRepositoryImpl({required this.userLocalDataSources});


@override
Future changePassword(ChangePasswordEntitie change_password_entitie) async {
  final session = await authService.getSession();
      
  if (session == null) {
    throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
  }
      
  change_password_entitie.id_cliente = int.tryParse(session.user.id_cliente);
  
  return userLocalDataSources.changePassword(change_password_entitie,session.token.access);
}
  
  @override
   Future<LoginResponse> loginUser(String username, String password, [String? base_datos]) async {
    return await userLocalDataSources.loginUser(username, password, base_datos);
  }
  
  @override
  Future registerUser(RegisterEntitie registerEntitie) {
    return userLocalDataSources.registerUser(registerEntitie);
  }

}
