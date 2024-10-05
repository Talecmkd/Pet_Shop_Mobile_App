import 'package:flutter/material.dart';
import '../Model/Pet.dart';
import '../Model/enum/PetEnum.dart';
import '../service/FirebaseService.dart';

class AddPetForm extends StatefulWidget {
  final Map<String, dynamic>? user;

  AddPetForm({required this.user});

  @override
  _AddPetFormState createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();

  PetEnum _selectedType = PetEnum.dog; // Initial value for pet type
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Pet'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.orange,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Pet Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet bio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<PetEnum>(
                value: _selectedType,
                items: PetEnum.values.where((type) => type != PetEnum.all).map((type) {
                  return DropdownMenuItem<PetEnum>(
                    value: type,
                    child: Text(type.name), // Use the name property from the enum
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pet Type',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: InputDecoration(
                  labelText: 'Owner Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imagePathController,
                decoration: InputDecoration(
                  labelText: 'Image Path',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image path';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });
                    // Construct pet object from form data
                    Pet pet = Pet(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      pet_type: _selectedType.name,
                      price: double.parse(_priceController.text),
                      owner: widget.user!['uid'],
                      imagePath: _imagePathController.text,
                      // Add other fields as needed
                    );

                    // Send the pet information to Firebase
                    _addPetToFirebase(pet);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to add the pet to Firebase
  void _addPetToFirebase(Pet pet) async {
    try {
      // Convert pet object to map
      Map<String, dynamic> petData = pet.toJson();

      // Call FirebaseService to add pet to database
      String? petId = await FirebaseService.addPetToDatabase(petData);

      if (petId != null) {
        // Pet added successfully, you can navigate to a different page if needed
        Navigator.pop(context);
      } else {
        // Error adding pet to database
        // Handle error here, if needed
      }
    } catch (error) {
      print('Error adding pet to Firebase: $error');
      // Handle error here, if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
