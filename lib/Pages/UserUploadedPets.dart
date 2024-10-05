import 'package:flutter/material.dart';
import '../Model/Pet.dart';
import 'PetDetailPage.dart';

class UserUploadedPets extends StatelessWidget {
  final List<Pet> _pets;
  final PageController _pageController;
  final Map<String, dynamic>? user;
  final bool canDelete;

  UserUploadedPets({
    Key? key,
    required List<Pet> pets,
    required PageController pageController,
    required this.user,
    required this.canDelete,
  })  : _pets = pets,
        _pageController = pageController,
        super(key: key);


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Pets I have to offer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PetDetailPage(petData: pet.toJson(), user: user, canDelete: canDelete,),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded( // Use Expanded to force the image to fit
                        child: SizedBox(
                          width: double.infinity,
                          height: 150,
                          child: Image.network(
                            pet.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(pet.name),
                      Text(
                        'Price: \$${pet.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
