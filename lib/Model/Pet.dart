import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/enum/PetEnum.dart';
class Pet {
  String? id; // Updated to allow null value
  final String name;
  final String description;
  final String owner;
  final double price;
  final String imagePath;
  final String pet_type;

  Pet({
    this.id,
    required this.name,
    required this.description,
    required this.owner,
    required this.price,
    required this.imagePath,
    required this.pet_type,
  });

  factory Pet.fromFirebase(Map<String, dynamic> data) {
    return Pet(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      owner: data['owner'],
      imagePath: data['imagePath'],
      price: data['price'],
      pet_type: data['pet_type'],
    );
  }

  // Convert Pet object to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id field if provided
      'name': name,
      'description': description,
      'owner': owner,
      'price': price,
      'imagePath': imagePath,
      'pet_type': pet_type,
    };
  }

  // Factory constructor to create Pet object from Map
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      // Keep id field if provided
      name: json['name'],
      description: json['description'],
      owner: json['owner'],
      price: json['price'],
      imagePath: json['imagePath'],
      pet_type: json['pet_type'],
    );
  }

  // Convert list of Pet objects to list of Maps
  static List<Map<String, dynamic>> petsToJson(List<Pet> pets) {
    return pets.map((pet) => pet.toJson()).toList();
  }
}