
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/repositories/reward_repository.dart';

class GetDataSellsUsecase {
  final RewardRepository rewardRepository;

  GetDataSellsUsecase({required this.rewardRepository});

  Future<List<GetDataSellsEntitie>> execute() async {
    return await rewardRepository.getDataSells();
  }
}