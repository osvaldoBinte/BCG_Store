import 'package:gerena/features/rewards/data/datasources/reward_local_data_sources.dart';
import 'package:gerena/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:gerena/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:gerena/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:gerena/features/rewards/domain/repositories/reward_repository.dart';
import 'package:gerena/common/services/auth_service.dart';
import 'package:gerena/features/users/data/models/login_response.dart';
import 'package:gerena/features/users/domain/repositories/user_repository.dart';

class RewardRepositoryImp implements RewardRepository {
  final RewardLocalDataSources rewardLocalDataSources;
  final UserRepository userRepository;
  final AuthService authService = AuthService();
  
  RewardRepositoryImp({
    required this.rewardLocalDataSources,
    required this.userRepository,
  });
  
  @override
  Future<List<CheckPointsEntitie>> getRewards() async {
    // Obtener todos los datos de sesión con una sola llamada
    final session = await authService.getSession();
    
    if (session == null) {
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    
    final token = session.token.access;
    final idCliente = session.user.id_cliente;
    
    final rewards = await rewardLocalDataSources.getRewards(token, idCliente);
    return rewards;
  }

  @override
  Future<List<ClientesAppRewardsEntitie>> getClientesAppRewards() async {
    final session = await authService.getSession();
    
    if (session == null) {
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    
    final token = session.token.access;
    final userId = session.user.id;
    
    final clientesAppRewards = await rewardLocalDataSources.getClientesAppRewards(token, userId);
    return clientesAppRewards;
  }

  Future<void> updateAccountData(ClientesAppRewardsEntitie clientesAppRewardsEntitie) async {
    final session = await authService.getSession();
    
    if (session == null) {
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    
    final token = session.token.access;
      clientesAppRewardsEntitie.id = session.user.id;

    final response = await rewardLocalDataSources.updateAccountData(token, clientesAppRewardsEntitie);
    return response;
  }

  @override
  Future<List<GetDataSellsEntitie>> getDataSells() async {
    final session = await authService.getSession();
    
    if (session == null) {
      throw Exception('No hay sesión activa. El usuario debe iniciar sesión.');
    }
    
    final token = session.token.access;
    final idCliente = session.user.id_cliente;
    
    final dataSells = await rewardLocalDataSources.getDataSells(token, idCliente);
    return dataSells;
  }
}