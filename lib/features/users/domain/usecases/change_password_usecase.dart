import 'package:BCG_Store/features/users/domain/entities/change_password_entitie.dart';
import 'package:BCG_Store/features/users/domain/repositories/user_repository.dart';

class ChangePasswordUsecase {
  final UserRepository userRepository;

  ChangePasswordUsecase({required this.userRepository});

   Future<void> execute(ChangePasswordEntitie change_password_entitie) async {
    await userRepository.changePassword(change_password_entitie);
  }
}