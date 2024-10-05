import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import '../Model/Pet.dart';
import '../service/FirebaseService.dart';
import 'UserUploadedPets.dart';

class OwnerProfilePage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  final Map<String, dynamic>? ownerUser;

  const OwnerProfilePage({Key? key, required this.loggedInUser, required this.ownerUser}) : super(key: key);

  @override
  _OwnerProfilePageState createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  List<Pet> ownerPets = [];

  @override
  void initState() {
    super.initState();
    _fetchOwnerPets();
  }

  Future<void> _fetchOwnerPets() async {
    try {
      if (widget.ownerUser != null && widget.ownerUser!.containsKey('uid')) {
        String ownerId = widget.ownerUser!['uid'];
        List<Pet> pets = await FirebaseService.fetchUserPets(ownerId);
        setState(() {
          ownerPets = pets;
        });
      }
    } catch (error) {
      print('Error fetching owner pets: $error');
      // Handle error if needed
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final whatsappUrl = 'https://wa.me/$phoneNumber';
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canDelete = widget.loggedInUser != null && widget.ownerUser != null && widget.loggedInUser!['uid'] == widget.ownerUser!['uid'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Owner ${widget.ownerUser?['name']} profile',
        ),
        backgroundColor: Colors.orangeAccent, // Set the app bar color
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Username: ${widget.ownerUser?['name']}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Role: ${widget.ownerUser?['buyer'] ? 'Buyer' : 'Seller'}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Bio: ${widget.ownerUser?['bio']}',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 10),
                if (widget.ownerUser!['seller'] && widget.ownerUser?['phone'] != null)
                  GestureDetector(
                    onTap: () {
                      _launchWhatsApp(widget.ownerUser!['phone']);
                    },
                    child: Text(
                      'Phone number: ${widget.ownerUser?['phone']}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                UserUploadedPets(
                  pageController: PageController(), // You may need to adjust this
                  pets: ownerPets, // Pass the list of owner pets
                  user: widget.loggedInUser,
                  canDelete: canDelete, // Pass the canDelete flag
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
