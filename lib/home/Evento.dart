import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goevent2/Controller/UserPreferences.dart';
import 'package:http/http.dart' as http;

class Evento {
  final int id;
  final String tituloEvento;
  final String imagenEvento; // Puede ser null
  final String imagenPortadaEvento; // Puede ser null
  final String fechaInicio;
  final String fechaFin;
  final String horaInicio;
  final String horaFin;
  final String precio;
  final String descripcionBreve;
  final String descripcion;
  final String? galeriaImagen1; // Puede ser null
  final String? galeriaImagen2; // Puede ser null
  final String? galeriaImagen3; // Puede ser null
  final String organizador;
  final String telefono;
  final String correo;
  final String tituloDireccion;
  final String direccionEvento;
  final double latitud;
  final double longitud;
  final int idUsuario;
  final int idMunicipio;
  final int idCategoria;
  final int idPublicoObjetivo;
  final int statusEvent;
  final bool statusActive;

  Evento({
    required this.id,
    required this.tituloEvento,
    required this.imagenEvento,
    required this.imagenPortadaEvento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    required this.precio,
    required this.descripcionBreve,
    required this.descripcion,
    this.galeriaImagen1,
    this.galeriaImagen2,
    this.galeriaImagen3,
    required this.organizador,
    required this.telefono,
    required this.correo,
    required this.tituloDireccion,
    required this.direccionEvento,
    required this.latitud,
    required this.longitud,
    required this.idUsuario,
    required this.idMunicipio,
    required this.idCategoria,
    required this.idPublicoObjetivo,
    required this.statusEvent,
    required this.statusActive,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0, // Valor predeterminado si es null
      tituloEvento: json['titulo_evento'] ?? '',
      imagenEvento: json['imagen_evento'], // Puede ser null
      imagenPortadaEvento: json['imagen_portada_evento'], // Puede ser null
      fechaInicio: formatDate(json['fecha_inicio']),
      fechaFin: formatDate(json['fecha_fin']),
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      precio: json['precio'] ?? '',
      descripcionBreve: json['descripcion_breve'] ?? '',
      descripcion: json['descripcion'] ?? '',
      galeriaImagen1: json['galeria_imagen_1'], // Puede ser null
      galeriaImagen2: json['galeria_imagen_2'], // Puede ser null
      galeriaImagen3: json['galeria_imagen_3'], // Puede ser null
      organizador: json['organizador'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      tituloDireccion: json['titulo_direccion'] ?? '',
      direccionEvento: json['direccion_evento'] ?? '',
      latitud: json['latitud'] != null ? double.tryParse(json['latitud']) ?? 0.0 : 0.0,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud']) ?? 0.0 : 0.0,
      idUsuario: json['id_usuario'] ?? 0,
      idMunicipio: json['id_municipio'] ?? 0,
      idCategoria: json['id_categoria'] ?? 0,
      idPublicoObjetivo: json['id_publico_objetivo'] ?? 0,
      statusEvent: json['status_event'] ?? 0,
      statusActive: json['status_active'] == 1,
    );
  }
  
  static String formatDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
}

}


class EventosService {

  Future<List<Evento>> cargarEventos() async {
  String apiUrl = 'http://216.225.205.93:3000/api/eventos/buscarEventos';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse['rta'] == true && jsonResponse['eventos'] is List) {
        List<dynamic> eventosJson = jsonResponse['eventos'];

        List<Evento> tempEventosList = [];

        for (var eventoJson in eventosJson) {
          int id = eventoJson['id'];

          // Obtener detalles del evento individual
          Evento evento = await obtenerDetallesEvento(id);
          tempEventosList.add(evento);
        }

        return tempEventosList;
      } else {
        throw Exception('La respuesta no contiene una lista de eventos.');
      }
    } else {
      throw Exception('Error al cargar eventos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al realizar la solicitud: $e');
  }
}
  
  
  Future<List<Evento>> cargarEventosEnUnaSemana() async {
  String apiUrl = 'http://216.225.205.93:3000/api/eventos/buscarEventos';

  DateTime ahora = DateTime.now();
  DateTime finSemana = ahora.add(Duration(days: 7));

  String fechaInicio = "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";
  String fechaFin = "${finSemana.year}-${finSemana.month.toString().padLeft(2, '0')}-${finSemana.day.toString().padLeft(2, '0')}";

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse['rta'] == true && jsonResponse['eventos'] is List) {
        List<dynamic> eventosJson = jsonResponse['eventos'];

        List<Evento> tempEventosList = [];

        for (var eventoJson in eventosJson) {
          int id = eventoJson['id'];

          // Obtener detalles del evento individual
          Evento evento = await obtenerDetallesEvento(id);
          tempEventosList.add(evento);
        }

        return tempEventosList;
      } else {
        throw Exception('La respuesta no contiene una lista de eventos.');
      }
    } else {
      throw Exception('Error al cargar eventos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al realizar la solicitud: $e');
  }
}



Future<List<Evento>> cargarEventosDelMes() async {
  final String apiUrl = 'http://216.225.205.93:3000/api/eventos/buscarEventos';

  DateTime ahora = DateTime.now();
  DateTime primerDiaMes = DateTime(ahora.year, ahora.month, 1);
  DateTime ultimoDiaMes = DateTime(ahora.year, ahora.month + 1, 0);

  String fechaInicio = "${primerDiaMes.year}-${primerDiaMes.month.toString().padLeft(2, '0')}-${primerDiaMes.day.toString().padLeft(2, '0')}";
  String fechaFin = "${ultimoDiaMes.year}-${ultimoDiaMes.month.toString().padLeft(2, '0')}-${ultimoDiaMes.day.toString().padLeft(2, '0')}";

  print('fechaInicio: $fechaInicio');
  print('fechaFin: $fechaFin');

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['rta'] == true) {
        List<dynamic> eventosJson = responseData['eventos'];
        List<Evento> eventos = eventosJson.map((eventoJson) => Evento.fromJson(eventoJson)).toList();
        return eventos;
      } else {
        print('Error en la respuesta: ${responseData['message']}');
        return [];
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error en la conexión: $e');
    return [];
  }
}

Future<List<Evento>> cargarEventosCategoria(int idCategoria) async {
  final String apiUrl = 'http://216.225.205.93:3000/api/eventos/buscarEventos';



  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_categoria': idCategoria
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['rta'] == true) {
        List<dynamic> eventosJson = responseData['eventos'];
        List<Evento> eventos = eventosJson.map((eventoJson) => Evento.fromJson(eventoJson)).toList();
        print('Eventossssss${eventosJson}');
        print('id cat: ${idCategoria}');
        return eventos;
      } else {
        print('Error en la respuesta: ${responseData['message']}');
        return [];
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error en la conexión: $e');
    return [];
  }
}

Future<List<Evento>> cargarEventosCercanos(String latitud, String longitud) async {
  final String apiUrl = 'http://216.225.205.93:3000/api/eventos/cercanos/$longitud/$latitud';
  List<Evento> eventosConDetalles = [];
  List<dynamic> eventosDistancia = [];

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);

      for (var eventoData in responseData) {
        int eventoId = eventoData['id'];
        Evento evento = await obtenerDetallesEvento(eventoId);
        eventosConDetalles.add(evento);
        
      }
      eventosDistancia = responseData;

    } else {
      print('Error en la solicitud de eventos cercanos: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en la conexión: $e');
  }

  return eventosConDetalles;
}


Future<List<Map<String, dynamic>>> obtenerEventosCercanos(
    String latitud, String longitud) async {
  final url = Uri.parse(
      'http://216.225.205.93:3000/api/eventos/cercanos/$longitud/$latitud');
  
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON y retornarla como una lista de mapas
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      // Manejar errores de la solicitud
      throw Exception('Error al obtener eventos cercanos');
    }
  } catch (e) {
    // Manejar cualquier excepción
    throw Exception('Error al realizar la solicitud: $e');
  }
}

Future<List<Evento>> obtenerEventosFavoritos() async {
  final String favoritosUrl = 'http://216.225.205.93:3000/api/favoritos/principales';

  try {
    final response = await http.get(
      Uri.parse(favoritosUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse['rta'] == true) {
        var favoritoList = jsonResponse['favorito'];

        if (favoritoList is List && favoritoList.isNotEmpty) {
          List<Evento> eventosFavoritos = [];

          for (var favoritoGroup in favoritoList) {
            var favoritos = favoritoGroup['Favoritos'];
            if (favoritos is List) {
              for (var favorito in favoritos) {
                int idEvento = favorito['id_event'];
                Evento evento = await obtenerDetallesEvento(idEvento);
                eventosFavoritos.add(evento);
              }
            }
          }

          return eventosFavoritos;
        }
      } else {
        print('Error en la respuesta: ${jsonResponse['message']}');
      }
    } else {
      print('Error al obtener favoritos: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en obtenerEventosFavoritos: $e');
  }

  return [];
}


Future<Evento> obtenerDetallesEvento(int id) async {
  final Uri url = Uri.parse('http://216.225.205.93:3000/api/eventos/$id');

  try {
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse['rta'] == true) {
        var eventoJson = jsonResponse['evento'];
        if (eventoJson != null && eventoJson is Map<String, dynamic>) {
          return Evento.fromJson(eventoJson);
        } else {
          throw Exception('La respuesta del servidor no contiene un evento válido.');
        }
      } else {
        throw Exception('Error al obtener detalles del evento.');
      }
    } else {
      throw Exception('Error al obtener detalles del evento: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en obtenerDetallesEvento: $e');
    throw Exception('Error al realizar la solicitud: $e');
  }
}

Future<List<dynamic>> obtenerFavoritos(int userId) async {
  final String apiUrl = 'http://216.225.205.93:3000/api/favoritos/byIdUser/$userId';
  

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse['rta'] == true) {
        var favoritoList = jsonResponse['favorito'];

        // Verificar si la lista 'favorito' no está vacía
        if (favoritoList is List && favoritoList.isNotEmpty) {
          return favoritoList;
        }
      } else {
        print('Error en la respuesta: ${jsonResponse['message']}');
      }
    } else {
      print('Error al obtener favoritos: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en obtenerFavoritos: $e');
  }

  return [];
}



Future<List<Evento>> obtenerEventosFavoritosPorId(int userId) async {
    final String apiUrl = 'http://216.225.205.93:3000/api/favoritos/byIdUser/$userId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        if (jsonResponse['rta'] == true) {
          var favoritoList = jsonResponse['favorito'];

          if (favoritoList is List && favoritoList.isNotEmpty) {
            List<Evento> eventosFavoritos = [];

            for (var favorito in favoritoList) {
              int idEvento = favorito['id_event'];
              Evento evento = await obtenerDetallesEvento(idEvento);
              eventosFavoritos.add(evento);
            }

            return eventosFavoritos;
          }
        } else {
          print('Error en la respuesta favorita: ${jsonResponse['message']}');
        }
      } else {
        print('Error al obtener favoritos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en obtenerEventosFavoritos: $e');
    }

    return [];
  }



Future<bool> crearFavorito(int userId, int eventId) async {
    final String apiUrl = 'http://216.225.205.93:3000/api/favoritos';
    final token = await UserPreferences.getToken();

    Map<String, dynamic> data = {
      'id_user': userId,
      'id_event': eventId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['rta'] == true) {
          print('Favorito creado correctamente');
          return true;
        } else {
          print('Error al crear favorito: ${jsonResponse['message']}');
        }
      } else {
        print('Error al crear favorito code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en crearFavorito: $e');
    }

    return false;
  }

  Future<bool> eliminarFavorito(int idUser, int idEvent) async {
    final String baseUrl = "http://216.225.205.93:3000/api/favoritos/$idEvent";
    final token = await UserPreferences.getToken();
    final url = Uri.parse(baseUrl);
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "id_user": idUser,
      "id_event": idEvent,
    });

    try {
      final response = await http.delete(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData['rta'] == true;
      } else {
        print('Error en la respuesta de la API: ${responseData['message']}');
        return false;
      }
    } catch (e) {
      print('Error al eliminar favorito: $e');
      return false;
    }
  }


}
