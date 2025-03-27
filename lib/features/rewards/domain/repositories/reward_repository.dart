import 'package:gerena/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:gerena/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:gerena/features/rewards/domain/entities/get_data_sells_entitie.dart';

abstract class RewardRepository {
  Future<List<CheckPointsEntitie>> getRewards();

  Future<List<ClientesAppRewardsEntitie>> getClientesAppRewards();
  Future<List<GetDataSellsEntitie>> getDataSells();

  Future<void> updateAccountData(ClientesAppRewardsEntitie clientesAppRewardsEntitie);
  }