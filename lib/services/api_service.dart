import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://143.198.118.203:8100/ejemplos/';
  static const String _user = 'test';
  static const String _pass = 'test2023';

  static Map<String, String> get _headers {
    final credenciales = base64Encode(utf8.encode('$_user:$_pass'));

    return {
      'Authorization': 'Basic $credenciales',
      'Content-Type': 'application/json',
    };
  }

  // Obtiene los registros de un módulo desde la API REST.
  static Future<List<Map<String, dynamic>>> listar(
    String endpoint,
    String clave,
  ) async {
    final respuesta = await http
        .get(Uri.parse('$_baseUrl$endpoint'), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (respuesta.statusCode != 200) {
      throw Exception('Error del servidor: ${respuesta.statusCode}');
    }

    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    final listado = datos[clave] as List;

    return listado
        .map((elemento) => Map<String, dynamic>.from(elemento))
        .toList();
  }

  // Envía información al servidor para agregar, editar o eliminar.
  static Future<void> enviar(
    String endpoint,
    Map<String, dynamic> datos,
  ) async {
    final respuesta = await http
        .post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(datos),
        )
        .timeout(const Duration(seconds: 15));

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception(
        'Error del servidor: ${respuesta.statusCode} - ${respuesta.body}',
      );
    }
  }
}
