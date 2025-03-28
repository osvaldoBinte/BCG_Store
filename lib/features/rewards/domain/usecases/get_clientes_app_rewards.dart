import 'package:BCG_Store/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/repositories/reward_repository.dart';
class GetClientesAppRewards {
  final RewardRepository rewardRepository;

  GetClientesAppRewards(this.rewardRepository);

  Future<List<ClientesAppRewardsEntitie>> execute() async {
      try {
        final result = await rewardRepository.getClientesAppRewards();
        return result;
      } catch (e) {
        print('❌ Error en GetClientesAppRewards: $e');
        rethrow;
      }
    }
}