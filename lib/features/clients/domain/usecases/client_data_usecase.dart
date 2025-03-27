import 'package:gerena/features/clients/domain/entities/client_data_entitie.dart';
import 'package:gerena/features/clients/domain/repositories/client_reporitoy.dart';

class ClientDataUsecase {
  final ClientRepository repository;

  ClientDataUsecase({required this.repository});

 Future<List<ClientDataEntitie>> execute() async {
    return await repository.getclientdata();
  }
}