
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/repositories/reward_repository.dart';

class CheckPointUsecase {
  final RewardRepository rewardRepository;
  
  CheckPointUsecase({required this.rewardRepository});
  
  Future<List<CheckPointsEntitie>> execute() async {
    try {
      final result = await rewardRepository.getRewards();
      
      if (result.isEmpty) {
        print('💡 La lista de recompensas está vacía');
        return [];
      }

      print('💡 Recompensas obtenidas: ${result.length}');
      return result;
    } catch (e) {
      print('❌ Error en CheckPointUsecase: $e');
      rethrow;
    }
  }
}