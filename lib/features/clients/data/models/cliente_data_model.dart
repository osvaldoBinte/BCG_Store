import 'package:BCG_Store/features/clients/domain/entities/client_data_entitie.dart';

class ClienteDataModel extends ClientDataEntitie {
  ClienteDataModel({
    required int id,
    String? correo,      // Modified to be nullable
    String? empresa,     // Modified to be nullable
    String? celular,     // Modified to be nullable
    String? domicilio,   // Modified to be nullable
    String? numext,      // Modified to be nullable
    String? numint,
    String? colonia,     // Modified to be nullable
    String? municipio,   // Modified to be nullable
    String? cp,          // Modified to be nullable
    String? estado,      // Modified to be nullable
    String? pais,        // Modified to be nullable
    String? rfc,         // Modified to be nullable
    String? regimenfiscal, // Modified to be nullable
    String? cfdi,        // Modified to be nullable
    String? url_qr,
  }) : super(
    id: id,
    correo: correo ?? '',      // Provide default value
    empresa: empresa ?? '',    // Provide default value
    celular: celular ?? '',    // Provide default value
    domicilio: domicilio ?? '', // Provide default value
    numext: numext ?? '',      // Provide default value
    numint: numint,
    colonia: colonia ?? '',    // Provide default value
    municipio: municipio ?? '', // Provide default value
    cp: cp ?? '',              // Provide default value
    estado: estado ?? '',      // Provide default value
    pais: pais ?? '',          // Provide default value
    rfc: rfc ?? '',            // Provide default value
    regimenfiscal: regimenfiscal ?? '', // Provide default value
    cfdi: cfdi ?? '',          // Provide default value
    url_qr: url_qr,
  );

   factory ClienteDataModel.fromJson(Map<String, dynamic> json) {
    return ClienteDataModel(
      id: json['id'] ?? 0,
      correo: json['correo'],
      empresa: json['empresa'],
      celular: json['celular'],
      domicilio: json['domicilio'],
      numext: json['numext'],
      numint: json['numint'],
      colonia: json['colonia'],
      municipio: json['municipio'],
      cp: json['cp'],
      estado: json['estado'],
      pais: json['pais'],
      rfc: json['rfc'],
      regimenfiscal: json['regimenfiscal'],
      cfdi: json['cfdi'],
      url_qr: json['url_qr'],
    );
  }
  factory ClienteDataModel.fromEntity(ClientDataEntitie clientDataEntitie) {
    return ClienteDataModel(
      id: clientDataEntitie.id,
      correo: clientDataEntitie.correo,
      empresa: clientDataEntitie.empresa,
      celular: clientDataEntitie.celular,
      domicilio: clientDataEntitie.domicilio,
      numext: clientDataEntitie.numext,
      numint: clientDataEntitie.numint,
      colonia: clientDataEntitie.colonia,
      municipio: clientDataEntitie.municipio,
      cp: clientDataEntitie.cp,
      estado: clientDataEntitie.estado,
      pais: clientDataEntitie.pais,
      rfc: clientDataEntitie.rfc,
      regimenfiscal: clientDataEntitie.regimenfiscal,
      cfdi: clientDataEntitie.cfdi,
      url_qr: clientDataEntitie.url_qr,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'empresa': empresa,
      'celular': celular,
      'domicilio': domicilio,
      'numext': numext,
      'numint': numint,
      'colonia': colonia,
      'municipio': municipio,
      'cp': cp,
      'estado': estado,
      'pais': pais,
      'rfc': rfc,
      'regimenfiscal': regimenfiscal,
      'cfdi': cfdi,
      'url_qr': url_qr,
    };
  }
}