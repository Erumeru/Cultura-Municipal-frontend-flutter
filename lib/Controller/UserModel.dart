import 'dart:convert';

class UserModel {
  final int userId;
  final String userName;
  final String name;
  final String lastName;
  final String email;
  final int? cellPhone;
  final int idMunicipio;    // Nuevo campo
  final int edad;           // Nuevo campo
  final String genero;      // Nuevo campo

  UserModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.lastName,
    required this.email,
    required this.cellPhone,
    required this.idMunicipio,   // Inicializar el nuevo campo
    required this.edad,          // Inicializar el nuevo campo
    required this.genero,        // Inicializar el nuevo campo
  });

  // Convert UserModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'name': name,
      'lastName': lastName,
      'email': email,
      'cellPhone': cellPhone,
      'idMunicipio': idMunicipio,  // Agregar al JSON
      'edad': edad,                // Agregar al JSON
      'genero': genero,            // Agregar al JSON
    };
  }

  // Create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      userName: json['userName'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      cellPhone: json['cellPhone'],
      idMunicipio: json['idMunicipio'],  // Extraer del JSON
      edad: json['edad'],                // Extraer del JSON
      genero: json['genero'],            // Extraer del JSON
    );
  }
}