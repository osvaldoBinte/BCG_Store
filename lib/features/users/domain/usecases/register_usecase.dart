import 'package:gerena/features/users/domain/entities/register_entitie.dart';
import 'package:gerena/features/users/domain/repositories/user_repository.dart';

class RegisterUsecase {
  final UserRepository userRepository;

  RegisterUsecase({required this.userRepository});

  Future<void> register(RegisterEntitie registerEntitie) async {
    return await userRepository.registerUser(registerEntitie);
  }
}