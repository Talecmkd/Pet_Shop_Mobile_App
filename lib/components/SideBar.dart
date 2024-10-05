import 'package:flutter/material.dart';
import '../Pages/BuyerPage.dart';
import '../Pages/FavouritePetsPage.dart';
import '../Pages/Authentication/LoginPage.dart';
import '../Pages/SellerPage.dart';
import '../Pages/UserProfilePage.dart';
import '../Pages/UserSettings.dart'; // Import the UserSettings page
import '../main.dart';

class SideBar extends StatelessWidget {
  final Map<String, dynamic>? user;
  final Function()? onAddPetPressed;

  SideBar({required this.user, required this.onAddPetPressed});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Background color for the DrawerHeader
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white, // Background color for the CircleAvatar
                  // You can add an image for the CircleAvatar here
                ),
                SizedBox(height: 10),
                Text(
                  user?['name'] ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.blue), // Icon color for the ListTile
            title: Text("Home", style: TextStyle(color: Colors.blue)), // Text color for the ListTile
            onTap: () {
              if (user?['seller'] == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SellerPage(user: user)),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BuyerPage(user: user)),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.blue), // Icon color for the ListTile
            title: Text("Profile", style: TextStyle(color: Colors.blue)), // Text color for the ListTile
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage(user: user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.blue), // Icon color for the ListTile
            title: Text("Favourites", style: TextStyle(color: Colors.blue)), // Text color for the ListTile
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavouritePetsPage(user: user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue), // Icon color for the ListTile
            title: Text("Settings", style: TextStyle(color: Colors.blue)), // Text color for the ListTile
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserSettings(user: user)),
              );
            },
          ),
          if (user?['seller'] == true)
            ListTile(
              leading: Icon(Icons.add, color: Colors.blue), // Icon color for the ListTile
              title: Text("Add Pet", style: TextStyle(color: Colors.blue)), // Text color for the ListTile
              onTap: onAddPetPressed,
            ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.blue), // Icon color for the ListTile
            title: Text("Logout", style: TextStyle(color: Colors.blue)), // Text color for the ListTile
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
