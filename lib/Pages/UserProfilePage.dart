import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/Pet.dart';
import '../components/PetDisplayWidget.dart';
import '../service/FirebaseService.dart';
import '../components/SideBar.dart';
import 'AddPetForm.dart';
import '../Pages/UserUploadedPets.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<Pet> userPets = [];

  @override
  void initState() {
    super.initState();
    _fetchUserPets();
  }

  Future<void> _fetchUserPets() async {
    try {
      if (widget.user != null && widget.user!.containsKey('uid')) {
        String userId = widget.user!['uid'];
        List<Pet> pets = await FirebaseService.fetchUserPets(userId);
        setState(() {
          userPets = pets;
        });
      }
    } catch (error) {
      print('Error fetching user pets: $error');
      // Handle error if needed
    }
  }

  void _navigateToAddPetPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetForm(user: widget.user),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunch(whatsappUrl.toString())) {
      await launch(whatsappUrl.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent, // Similar color to other pages
        title: Text(
          'User Profile',

        ),
      ),
      drawer: SideBar(
        user: widget.user,
        onAddPetPressed: _navigateToAddPetPage,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserInfoItem(
                  label: 'Username',
                  value: widget.user?['name'],
                ),
                SizedBox(height: 10),
                UserInfoItem(
                  label: 'Role',
                  value: widget.user?['buyer'] ? 'Buyer' : 'Seller',
                ),
                SizedBox(height: 10),
                UserInfoItem(
                  label: 'Bio',
                  value: widget.user?['bio'],
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    if (widget.user?['phone'] != null && widget.user!['seller']) {
                      _launchWhatsApp(widget.user!['phone']);
                    }
                  },
                  child: UserInfoItem(
                    label: 'Phone number',
                    value: widget.user?['phone'],
                    isClickable: widget.user!['seller'],
                  ),
                ),
                SizedBox(height: 20),
                if (widget.user!['seller'])
                  UserUploadedPets(
                    pageController: PageController(),
                    pets: userPets,
                    user: widget.user,
                    canDelete: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserInfoItem extends StatelessWidget {
  final String? label;
  final String? value;
  final bool isClickable;
  final Function()? onTap;

  const UserInfoItem({
    Key? key,
    required this.label,
    required this.value,
    this.isClickable = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: onTap,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 18,
                color: isClickable ? Colors.blue : Colors.black,
                decoration: isClickable ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
