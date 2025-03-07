import 'dart:convert';

class UserModel {
  final int userId;
  final String userName;
  final String name;
  final String lastName;
  final String email;
  final int ?cellPhone;

  UserModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.lastName,
    required this.email,
    required this.cellPhone,
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
    );
  }
}
