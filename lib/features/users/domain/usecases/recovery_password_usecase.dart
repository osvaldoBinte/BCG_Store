import 'package:BCG_Store/features/users/domain/repositories/user_repository.dart';

class RecoveryPasswordUsecase {
  final UserRepository userRepository;
  RecoveryPasswordUsecase({
    required this.userRepository,
  });
  Future<void> execute(String email) async {
    return await userRepository.recoveryPassword(email);
  }
} 