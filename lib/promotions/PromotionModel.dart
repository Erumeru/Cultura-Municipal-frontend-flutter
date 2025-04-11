class PromotionModel {
    int id;
    int idMunicipio;
    String mensaje;
    String imagen;
    String fechaCreacion;
    bool statusActive;
    String generoDestino;
    int edadMinima;
    int edadMaxima;

  PromotionModel({
        required this.id,
        required this.idMunicipio,
        required this.mensaje,
        required this.imagen,
        required this.fechaCreacion,
        required this.statusActive,
        required this.generoDestino,
        required this.edadMinima,
        required this.edadMaxima,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] ?? 0,
      mensaje: json['mensaje'] ?? '',
      fechaCreacion: json['fechaCreacion'] ?? '',
      imagen: json['imagen'] ?? '',
      statusActive: json['statusActive'] ?? '',
      idMunicipio: json['idMunicipio'] ?? 0,
      generoDestino: json['generoDestino'] ?? '',
      edadMinima: json['edadMinima'] ?? 0,
      edadMaxima: json['edadMaxima'] ?? 0,
    );
  }
}