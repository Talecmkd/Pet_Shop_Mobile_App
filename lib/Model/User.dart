import 'Pet.dart';

class User {
  final String username;
  final String password;
  final String role;
  List<Pet> favouritePets;
  String bio;
  User({required this.username,
    required this.password,
    required this.role,
    List<Pet>? favouritePets, String? bio})
      :this.favouritePets=favouritePets??[],
        this.bio=bio??"";

  void addToFavourites(Pet pet){
    if(!favouritePets.contains(pet))
      favouritePets.add(pet);
  }
  void removeFromFavourites(Pet pet){
    this.favouritePets.remove(pet);
  }
}
List<User> mockUsers =[
  User(username:"buyer",password:"buyer",role:"buyer",bio:"I am a buyer hello!"),
  User(username: "seller", password: "seller", role:"seller"),
];