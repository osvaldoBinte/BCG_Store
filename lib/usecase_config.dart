import 'package:BCG_Store/features/clients/data/datasources/client_local_data_sources.dart';
import 'package:BCG_Store/features/clients/data/repositories/client_repository_imp.dart';
import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/rewards/data/datasources/reward_local_data_sources.dart';
import 'package:BCG_Store/features/rewards/data/repositories/reward_repository_imp.dart';
import 'package:BCG_Store/features/rewards/domain/repositories/reward_repository.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/check_point_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_clientes_app_rewards.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_data_sells_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/update_account_data_usecase.dart';
import 'package:BCG_Store/features/users/data/datasources/user_local_data_sources.dart';
import 'package:BCG_Store/features/users/data/repositories/user_repository_imp.dart';
import 'package:BCG_Store/features/users/domain/usecases/change_password_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/login_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/recovery_password_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/register_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/update_token_usecase.dart';

class UsecaseConfig {
  UserLocalDataSourcesImp? userLocalDataSourcesImp;
  UserRepositoryImpl? userRepositoryImpl;
  RegisterUsecase? registerUsecase;
  LoginUsecase? loginUsecase;
  ChangePasswordUsecase? changePasswordUsecase;
  RecoveryPasswordUsecase? recoveryPasswordUsecase;

  RewardLocalDataSourcesImpl? rewardLocalDataSourcesImpl;
  RewardRepositoryImp? rewardRepositoryImpl; 
  CheckPointUsecase? checkPointUsecase;

  ClientLocalDataSourcesImp? clientLocalDataSourcesImp;
  ClientRepositoryImp? clientRepositoryImpl;
  ClientDataUsecase? clientedataUsecase;
  GetClientesAppRewards? getClientesAppRewards;
  UpdateAccountDataUsecase? updateAccountDataUsecase;
  GetDataSellsUsecase? getDataSellsUsecase;
  UpdateTokenUsecase? updateTokenUsecase;

    UsecaseConfig(){
    userLocalDataSourcesImp = UserLocalDataSourcesImp();
    userRepositoryImpl = UserRepositoryImpl(userLocalDataSources: userLocalDataSourcesImp!);
    registerUsecase = RegisterUsecase(userRepository: userRepositoryImpl!);
    loginUsecase = LoginUsecase(userRepository: userRepositoryImpl!);
    changePasswordUsecase = ChangePasswordUsecase(userRepository: userRepositoryImpl!);
    recoveryPasswordUsecase = RecoveryPasswordUsecase(userRepository: userRepositoryImpl!);
    updateTokenUsecase = UpdateTokenUsecase(userRepository: userRepositoryImpl!);

    rewardLocalDataSourcesImpl = RewardLocalDataSourcesImpl();
    rewardRepositoryImpl = RewardRepositoryImp(rewardLocalDataSources: rewardLocalDataSourcesImpl!, userRepository: userRepositoryImpl!);
    checkPointUsecase = CheckPointUsecase(rewardRepository: rewardRepositoryImpl!);

    clientLocalDataSourcesImp = ClientLocalDataSourcesImp();
    clientRepositoryImpl = ClientRepositoryImp(clientLocalDataSources: clientLocalDataSourcesImp!);
    clientedataUsecase = ClientDataUsecase(repository:  clientRepositoryImpl!);
    getClientesAppRewards = GetClientesAppRewards(rewardRepositoryImpl!);
    updateAccountDataUsecase = UpdateAccountDataUsecase(rewardRepositoryImpl!);
    getDataSellsUsecase = GetDataSellsUsecase(rewardRepository: rewardRepositoryImpl!);
    }
}