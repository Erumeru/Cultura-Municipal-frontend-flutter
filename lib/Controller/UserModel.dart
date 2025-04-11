import 'dart:convert';

class UserModel {
  final int userId;
  final String userName;
  final String name;
  final String lastName;
  final String email;
  final int? cellPhone;
  final int idMunicipio;    
  final int edad;           
  final String genero;      

  UserModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.lastName,
    required this.email,
    required this.cellPhone,
    required this.idMunicipio,   
    required this.edad,         
    required this.genero,        
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
      'idMunicipio': idMunicipio, 
      'edad': edad,               
      'genero': genero,          
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
      idMunicipio: json['idMunicipio'], 
      edad: json['edad'],               
      genero: json['genero'],           
    );
  }
}