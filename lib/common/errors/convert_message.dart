import 'dart:async';
import 'dart:io';

String convertMessageException({required dynamic error}) {
  switch (error) {
    case SocketException:
      return 'Servicio no disponible intente mas tarde';
    case TimeoutException:
      return 'La peticion tardo mas  de lo usual, intente de nuevo';
    default:
      return error.toString();
  }
}