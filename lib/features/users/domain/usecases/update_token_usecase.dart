import 'package:BCG_Store/features/users/domain/repositories/user_repository.dart';

class UpdateTokenUsecase {
  final UserRepository userRepository;

  UpdateTokenUsecase({required this.userRepository});

  Future<void> execute(String? token_device) async {
    await userRepository.updatetoken(token_device);
  }
}