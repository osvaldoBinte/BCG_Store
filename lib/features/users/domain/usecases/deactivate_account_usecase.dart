import 'package:BCG_Store/features/users/domain/repositories/user_repository.dart';

class DeactivateAccountUsecase {
  final UserRepository userRepository;

  DeactivateAccountUsecase({required this.userRepository});

  Future<void> execute(String password) async {
    await userRepository.deactivateaccount(password);
  }
}