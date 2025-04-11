import 'package:goevent2/Api/ApiWrapper.dart';
import 'package:goevent2/promotions/PromotionModel.dart';

class PromotionsController {
  Future<List<PromotionModel>> getFilteredPromotions({
    String? gender,
    int? age,
    int? idMunicipio,
  }) async {
    print(
        '🔍 Cargar anuncios para edad $age, género $gender, municipio $idMunicipio');

    final body = {
      'genero': gender,
      'edad': age,
      'idMunicipio': idMunicipio,
    };

    try {
      final responseJson = await ApiWrapper.postData('http://216.225.205.93:3000/api/anuncios/filtrar', body);

      if (responseJson != null &&
          responseJson["rta"] == true &&
          responseJson["anuncios"] != null &&
          responseJson["anuncios"] is List) {
        List<dynamic> anuncios = responseJson["anuncios"];
        return anuncios
            .map((json) => PromotionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      print('❌ Error fetching promotions: $e');
      throw Exception('Failed to load promotions');
    }
  }
}
