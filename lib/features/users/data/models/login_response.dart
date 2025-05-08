class LoginResponse {
  final String message;
  final UserData user;
  final TokenData token;
  final String tienda_activa;
  final String? sitioWeb; 


  LoginResponse({
    required this.message, 
    required this.user, 
    required this.token,
    required this.tienda_activa,
    this.sitioWeb,

  });

   factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: UserData.fromJson(json['user']),
      token: TokenData.fromJson(json['token']),
      tienda_activa: json['tienda_activa'] ?? '',
      sitioWeb: json['sitio_web'] == null || json['sitio_web'] == ''
          ? null
          : json['sitio_web'],
    );
  }
}class UserData {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String id_cliente;

  UserData({
    required this.id, 
    required this.email, 
    required this.firstName, 
    required this.lastName,
    required this.id_cliente
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      id_cliente: json['id_cliente'] ?? '',

    );
  }
}

class TokenData {
  final String refresh;
  final String access;

  TokenData({required this.refresh, required this.access});

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      refresh: json['refresh'] ?? '',
      access: json['access'] ?? '',
    );
  }
}