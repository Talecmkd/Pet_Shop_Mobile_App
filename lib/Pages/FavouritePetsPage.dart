import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/Pet.dart';
import 'PetDetailPage.dart';
import '../components/SideBar.dart';
import 'dart:convert';

import 'AddPetForm.dart';

class FavouritePetsPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  FavouritePetsPage({required this.user});
  @override
  State<FavouritePetsPage> createState() => _FavouritePetsPageState();
}

class _FavouritePetsPageState extends State<FavouritePetsPage> {
  String ownerName="";
  bool canDelete=false;
  @override
  Widget build(BuildContext context) {
    if (widget.user!['seller']) canDelete = true;
    final String? favouritePetsData = widget.user?['favouritePets'];
    List<dynamic>? favouritePetsJson;
    if (favouritePetsData != null && favouritePetsData.isNotEmpty) {
      favouritePetsJson = jsonDecode(favouritePetsData) as List<dynamic>?;
    }

    void _navigateToAddPetPage() {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPetForm(user: widget.user)));
    }

    Function()? onAddPetPressed;
    if (widget.user?['seller']) {
      onAddPetPressed = _navigateToAddPetPage;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Pets'),
        backgroundColor: Colors.orange,
      ),
      drawer: SideBar(
        user: widget.user,
        onAddPetPressed: onAddPetPressed,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 2 / 3, // Aspect ratio for the cards
            ),
            itemCount: favouritePetsJson?.length ?? 0,
            itemBuilder: (context, index) {
              if (favouritePetsJson != null && index < favouritePetsJson.length) {
                final Map<String, dynamic> petData =
                favouritePetsJson[index] as Map<String, dynamic>;
                return FutureBuilder<Pet?>(
                  future: fetchPetData(petData['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final Pet pet = snapshot.data!;
                      return Card(
                        elevation: 4.0,
                        color: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetDetailPage(
                                  petData: pet.toJson(),
                                  user: widget.user,
                                  canDelete: canDelete,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                                child: Image.network(
                                  pet.imagePath,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  pet.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: FutureBuilder<String>(
                                  future: fetchOwnerName(pet.owner),
                                  builder: (context, ownerSnapshot) {
                                    if (ownerSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Owner: Loading...',
                                          style: TextStyle(color: Colors.white));
                                    } else if (ownerSnapshot.hasError) {
                                      return Text('Owner: Error',
                                          style: TextStyle(color: Colors.white));
                                    } else {
                                      return Text('Owner: ${ownerSnapshot.data}',
                                          style: TextStyle(color: Colors.white));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }



  Future<Pet?> fetchPetData(String petId) async {
      DocumentSnapshot petSnapshot = await FirebaseFirestore.instance.collection('pets').doc(petId).get();
      if (petSnapshot.exists) {
        return Pet.fromJson(petSnapshot.data() as Map<String, dynamic>);
      }
      else{
        return null;
      }

  }

  Future<String> fetchOwnerName(String ownerId) async {
    try {
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .get();

      if (ownerSnapshot.exists) {
        return ownerSnapshot['name'];
      } else {
        return 'Unknown'; // or any default value
      }
    } catch (error) {
      print('Error fetching owner name: $error');
      return 'Error'; // or any error message
    }
  }}
