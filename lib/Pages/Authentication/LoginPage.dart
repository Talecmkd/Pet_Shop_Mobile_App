import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../BuyerPage.dart';
import '../SellerPage.dart';
import 'RegistrationPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginButtonHovered = false;
  bool _isRegisterButtonHovered = false;

  void _loginUser() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Email and password are required.");
      return;
    }

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        if (userData != null) {
          bool isBuyer = userData['buyer'] ?? false;
          bool isSeller = userData['seller'] ?? false;

          if (isBuyer && isSeller) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SellerPage(user: userData)),
            );
          } else if (isBuyer) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BuyerPage(user: userData)),
            );
          } else if (isSeller) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SellerPage(user: userData)),
            );
          } else {
            _showSnackbar("No valid role assigned to this user.");
          }
        } else {
          _showSnackbar("Failed to retrieve user data.");
        }
      } else {
        _showSnackbar("User does not exist in the database.");
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided.";
      } else {
        message = "Login failed: ${e.message}";
      }
      _showSnackbar(message);
    } catch (e) {
      print("Error logging in user: $e");
      _showSnackbar("Login failed: $e");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fur & Feathers Haven'),
        backgroundColor: Colors.orangeAccent, // Happy color for the app bar
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade700], // Warm gradient colors
          ),
        ),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to Fur & Feathers Haven',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Where Love Finds a Tail to Wag',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loginUser,
                  onHover: (hover) {
                    setState(() {
                      _isLoginButtonHovered = hover;
                    });
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: _isLoginButtonHovered ? Colors.black : Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      _isLoginButtonHovered ? Colors.white : Colors.orange,
                    ),
                    elevation: MaterialStateProperty.resolveWith<double>((states) {
                      return _isLoginButtonHovered ? 8 : 0;
                    }),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                  onHover: (hover) {
                    setState(() {
                      _isRegisterButtonHovered = hover;
                    });
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: _isRegisterButtonHovered ? Colors.black : Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Colors.white),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 40), // Added some space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
