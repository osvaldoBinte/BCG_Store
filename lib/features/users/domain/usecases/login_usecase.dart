import 'package:BCG_Store/features/users/data/models/login_response.dart';
import 'package:BCG_Store/features/users/domain/repositories/user_repository.dart';


class LoginUsecase {
  final UserRepository userRepository;

  LoginUsecase({required this.userRepository});

  Future<LoginResponse> execute(String username, String password, [String? base_datos]) async {
    return await userRepository.loginUser(username, password, base_datos);
  }
}