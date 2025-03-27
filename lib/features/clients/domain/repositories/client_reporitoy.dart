import 'package:gerena/features/clients/domain/entities/client_data_entitie.dart';

abstract class ClientRepository {
  Future<List<ClientDataEntitie>> getclientdata();
}