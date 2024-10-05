import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_pet_shop/service/FirebaseService.dart';
import 'package:flutter/material.dart';
import 'Model/Pet.dart';
import 'Model/User.dart';
import 'Pages/BuyerPage.dart';
import 'Pages/Authentication/LoginPage.dart';
import 'Pages/SellerPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';



Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(PetShopApp());
}

class PetShopApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title:'Pet Shop App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(),
      );
  }

}

