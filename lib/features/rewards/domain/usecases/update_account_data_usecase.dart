
import 'package:BCG_Store/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/repositories/reward_repository.dart';

class UpdateAccountDataUsecase {
  final RewardRepository rewardRepository;

  UpdateAccountDataUsecase(this.rewardRepository);

  
  Future<void> execute(ClientesAppRewardsEntitie clientesAppRewardsEntitie) async {
      try {
        
        return  await rewardRepository.updateAccountData(clientesAppRewardsEntitie) ;
      } catch (e) {
        print('❌ Error en update_account_data: $e');
        rethrow;
      }
    }
}