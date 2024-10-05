import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Pet.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Pet>> fetchUserPets(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('pets')
          .where('owner', isEqualTo: userId)
          .get();

      List<Pet> userPets = [];
      querySnapshot.docs.forEach((doc) {
        userPets.add(Pet.fromFirebase(doc.data() as Map<String, dynamic>));
      });

      return userPets;
    } catch (error) {
      print('Error fetching user pets: $error');
      throw error; // Rethrow the error to handle it in the calling code
    }
  }
  static Future<bool> checkIfPetExists(String petId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .get();

      return documentSnapshot.exists;
    } catch (error) {
      print('Error checking if pet exists: $error');
      return false;
    }
  }


  static Future<String?> addPetToDatabase(Map<String, dynamic> petData) async {
    try {
      // Convert the pet data to a Pet object
      Pet pet = Pet.fromFirebase(petData);

      bool petExists = await checkIfPetExists(pet.id??'');
      if (petExists) {
        print('Pet with the same id already exists in the database');
        await _firestore.collection('pets').doc(pet.id).update(petData);
        print("Updated!");
        return pet.id;
      }

      // Add the pet data to Firestore with auto-generated ID
      DocumentReference petRef = await _firestore.collection('pets').add(petData);

      print('Pet added to the database successfully with ID: ${petRef.id}');
      await petRef.update({'id': petRef.id});

      // Return the ID of the newly added document
      return petRef.id;
    } catch (error) {
      print('Error adding pet to the database: $error');
      // You can handle the error here
      return null;
    }
  }
}
