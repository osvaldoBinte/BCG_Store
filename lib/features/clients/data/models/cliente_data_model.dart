import 'package:BCG_Store/features/clients/domain/entities/client_data_entitie.dart';

class ClienteDataModel  extends ClientDataEntitie{

  ClienteDataModel({
    required int id,
    required String correo,
    required String empresa,
    required String celular,
    required String domicilio,
    required String numext,
    String? numint,
    required String colonia,
    required String municipio,
    required String cp,
    required String estado,
    required String pais,
    required String rfc,
    required String regimenfiscal,
    required String cfdi,
    String? url_qr,
  }) : super(
    id: id,
    correo: correo,
    empresa: empresa,
    celular: celular,
    domicilio: domicilio,
    numext: numext,
    numint: numint,
    colonia: colonia,
    municipio: municipio,
    cp: cp,
    estado: estado,
    pais: pais,
    rfc: rfc,
    regimenfiscal: regimenfiscal,
    cfdi: cfdi,
    url_qr: url_qr,
  );

  factory ClienteDataModel.fromJson(Map<String, dynamic> json) {
    return ClienteDataModel(
      id: json['id'],
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