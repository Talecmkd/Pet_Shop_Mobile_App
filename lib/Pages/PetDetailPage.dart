import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_pet_shop/Pages/OwnerProfilePage.dart';
import 'package:flutter/material.dart';
import 'UserProfilePage.dart';
import '../service/FirebaseService.dart';

class PetDetailPage extends StatefulWidget {
  final Map<String, dynamic> petData;
  final Map<String, dynamic>? user;
  final bool canDelete;

  const PetDetailPage({
    Key? key,
    required this.petData,
    required this.user,
    required this.canDelete,
  }) : super(key: key);

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  bool isFavourite = false;
  String ownerName = "";

  @override
  void initState() {
    super.initState();
    _checkIfFavourite();
    _fetchOwnerName();
  }

  Future<void> _fetchOwnerName() async {
    try {
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.petData['owner'])
          .get();

      if (ownerSnapshot.exists) {
        setState(() {
          ownerName = ownerSnapshot['name'];
        });
      } else {
        setState(() {
          ownerName = 'Unknown'; // or any default value
        });
      }
    } catch (error) {
      print('Error fetching owner name: $error');
      setState(() {
        ownerName = 'Error'; // or any error message
      });
    }
  }

  void _checkIfFavourite() {
    if (widget.user != null && widget.user!.containsKey('favouritePets')) {
      final dynamic favouritePetsData = widget.user!['favouritePets'];
      if (favouritePetsData is String && favouritePetsData.isNotEmpty) {
        final List<dynamic> favouritePetsJson = json.decode(favouritePetsData);
        setState(() {
          isFavourite = favouritePetsJson.any((petData) => petData['id'] == widget.petData['id']);
        });
      }
    }
  }

  Future<void> _toggleFavourite() async {
    if (widget.user == null || !widget.user!.containsKey("uid")) return;

    final userId = widget.user!['uid'];
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      DocumentSnapshot docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        throw Exception("User document does not exist");
      }

      final dynamic favouritePetsData = docSnapshot['favouritePets'] ?? '';
      final List<dynamic> favouritePetsJson = favouritePetsData.isNotEmpty
          ? json.decode(favouritePetsData)
          : [];

      if (isFavourite) {
        // Remove from favourites
        setState(() {
          isFavourite = false;
        });

        favouritePetsJson.removeWhere((petData) => petData['id'] == widget.petData['id']);
        final updatedFavouritePets = json.encode(favouritePetsJson);

        await userDoc.update({'favouritePets': updatedFavouritePets});
        widget.user!['favouritePets'] = updatedFavouritePets;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.petData['name']} removed from favourites!'),
          ),
        );
      } else {
        // Add to favourites
        setState(() {
          isFavourite = true;
        });

        String? petId = await FirebaseService.addPetToDatabase(widget.petData);

        if (petId != null) {
          // Use the Firebase-generated ID when adding the pet to favourites
          widget.petData['id'] = petId;
          favouritePetsJson.add(widget.petData);
          final updatedFavouritePets = json.encode(favouritePetsJson);

          await userDoc.update({'favouritePets': updatedFavouritePets});
          widget.user!['favouritePets'] = updatedFavouritePets;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.petData['name']} added to favourites!'),
            ),
          );
        }
      }
    } catch (e) {
      print("Error updating favourites: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favourites: $e'),
        ),
      );
    }
  }

  Future<void> _deletePet() async {
    if (widget.user != null && widget.user!.containsKey('uid')) {
      try {
        String petId = widget.petData['id'];
        String userId = widget.user!['uid'];

        // Remove pet from user's favorites list
        final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await userDoc.get();

        if (userSnapshot.exists) {
          final dynamic favouritePetsData = userSnapshot['favouritePets'] ?? '';
          final List<dynamic> favouritePetsJson = favouritePetsData.isNotEmpty
              ? json.decode(favouritePetsData)
              : [];

          favouritePetsJson.removeWhere((petData) => petData['id'] == petId);
          final updatedFavouritePets = json.encode(favouritePetsJson);

          await userDoc.update({'favouritePets': updatedFavouritePets});
          widget.user!['favouritePets'] = updatedFavouritePets;
        }

        // Delete pet document from Firestore
        await FirebaseFirestore.instance.collection('pets').doc(petId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.petData['name']} deleted successfully!'),
          ),
        );
        Navigator.pop(context); // Navigate back after deleting
      } catch (error) {
        print('Error deleting pet: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting pet: $error'),
          ),
        );
      }
    }
  }

  Future<void> _fetchOwner() async {
    try {
      String ownerId = widget.petData['owner'];
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .get();

      if (ownerSnapshot.exists) {
        Map<String, dynamic> ownerData = ownerSnapshot.data() as Map<String, dynamic>;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerProfilePage(
              loggedInUser: widget.user,
              ownerUser: ownerData,
            ),
          ),
        );
      } else {
        // Handle case where owner does not exist
      }
    } catch (error) {
      print('Error fetching owner data: $error');
// Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.user != null && widget.user!['uid'] == widget.petData['owner'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Pet Details"),
        backgroundColor: Colors.orangeAccent, // Set app bar color
      ),
      body: Center(
        child: Container(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0), // Reduce padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(
                    widget.petData['imagePath'],
                    width: MediaQuery.of(context).size.width * 0.6,

                  ),
                  SizedBox(height: 12), // Reduce spacing
                  GestureDetector(
                    onTap: _fetchOwner,
                    child: Text(
                      "Owner: $ownerName",
                      style: TextStyle(fontSize: 14, color: Colors.blue), // Reduce font size
                    ),
                  ),
                  SizedBox(height: 12), // Reduce spacing
                  Text(
                    "Description: ${widget.petData['description']}",
                    style: TextStyle(fontSize: 14), // Reduce font size
                  ),
                  SizedBox(height: 12), // Reduce spacing
                  Text(
                    "Price: \$${widget.petData['price']}",
                    style: TextStyle(fontSize: 14), // Reduce font size
                  ),
                  SizedBox(height: 12), // Reduce spacing
                  ElevatedButton(
                    onPressed: _toggleFavourite,
                    child: Text(isFavourite ? "Remove from favourites!" : "Add to favourites!"),
                  ),
                  if (isOwner) ...[
                    SizedBox(height: 12), // Reduce spacing
                    ElevatedButton(
                      onPressed: _deletePet,
                      child: Text("Delete Pet!"),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }





}
