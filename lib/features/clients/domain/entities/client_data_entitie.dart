class ClientDataEntitie {
  final int id;
  final String correo;
  final String empresa;
  final String celular;
  final String domicilio;
  final String numext;
  final String? numint;  
  final String colonia;
  final String municipio;
  final String cp;
  final String estado;
  final String pais;
  final String rfc;
  final String regimenfiscal;
  final String cfdi;
  final String? url_qr; 

  ClientDataEntitie({
    required this.id,
    required this.correo,
    required this.empresa,
    required this.celular,
    required this.domicilio,
    required this.numext,
    this.numint,
    required this.colonia,
    required this.municipio,
    required this.cp,
    required this.estado,
    required this.pais,
    required this.rfc,
    required this.regimenfiscal,
    required this.cfdi,
    this.url_qr,
  });

}