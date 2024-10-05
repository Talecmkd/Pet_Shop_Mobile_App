import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'LoginPage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController(); // Add bio controller
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');  // Initialize with a default country code

  bool _isBuyer = false;
  bool _isSeller = false;

  void _registerUser() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance.collection("users").where(
          'username', isEqualTo: _usernameController.text)
          .get();
      if (snapshot.docs.isEmpty) {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _usernameController.text.trim(),
            password: _passwordController.text.trim());
        String phoneNumber = _phoneNumber.phoneNumber ?? '';
        await FirebaseFirestore.instance.collection("users").doc(
            userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text,
          'surname': _surnameController.text,
          'email': _usernameController.text,
          'password': _passwordController.text,
          'phone': phoneNumber,  // Update phone number
          'buyer': _isBuyer,
          'seller': _isSeller,
          'bio': _bioController.text,  // Add bio field
          'favouritePets': "",
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Email already exists!")));
      }
    }
    on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = "The email address is already in use by another account.";
      } else if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      } else {
        message = "Registration failed: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      print("Error registering user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e"))
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.orange.shade400,
                padding: EdgeInsets.all(16.0),
                height: constraints.maxHeight - MediaQuery.of(context).viewInsets.bottom,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name', fillColor: Colors.white),
                      ),
                      TextField(
                        controller: _surnameController,
                        decoration: InputDecoration(labelText: 'Surname', fillColor: Colors.white),
                      ),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username', fillColor: Colors.white),
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password', fillColor: Colors.white),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          _phoneNumber = number;
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.DROPDOWN,
                        ),
                        initialValue: _phoneNumber,
                        textFieldController: TextEditingController(),
                        inputDecoration: InputDecoration(
                          labelText: 'Phone Number',
                          fillColor: Colors.white,
                        ),
                      ),
                      TextField(
                        controller: _bioController,
                        decoration: InputDecoration(labelText: 'Bio', fillColor: Colors.white),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        title: Text('Register as Buyer'),
                        value: _isBuyer,
                        onChanged: (newValue) {
                          setState(() {
                            _isBuyer = newValue!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Register as Seller'),
                        value: _isSeller,
                        onChanged: (newValue) {
                          setState(() {
                            _isSeller = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _registerUser();
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
