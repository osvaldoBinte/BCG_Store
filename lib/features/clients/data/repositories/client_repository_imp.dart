
import 'package:BCG_Store/common/services/auth_service.dart';
import 'package:BCG_Store/features/clients/data/datasources/client_local_data_sources.dart';
import 'package:BCG_Store/features/clients/domain/entities/client_data_entitie.dart';
import 'package:BCG_Store/features/clients/domain/repositories/client_reporitoy.dart';

class ClientRepositoryImp implements ClientRepository  {
  final ClientLocalDataSources clientLocalDataSources;
    final AuthService authService = AuthService();

  ClientRepositoryImp({required this.clientLocalDataSources});
  @override
  Future<List<ClientDataEntitie>> getclientdata() async {

  final session = await authService.getSession();
    
    if (session == null) {
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    
    final token = session.token.access;
    return await clientLocalDataSources.getclientdata(token);
  }
  

}