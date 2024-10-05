import 'package:flutter/material.dart';
import '../Model/enum/PetEnum.dart';

class PetFilterDropdown extends StatelessWidget {
  final PetEnum? selectedType;
  final ValueChanged<PetEnum?> onChanged;

  const PetFilterDropdown({
    Key? key,
    required this.selectedType,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PetEnum>(
      value: selectedType,
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down), // Add an arrow icon to indicate dropdown
      iconSize: 24, // Set the size of the dropdown icon
      elevation: 16, // Set the elevation of the dropdown menu
      style: TextStyle(color: Colors.blue), // Text style for dropdown items
      underline: Container( // Customize the underline
        height: 2,
        color: Colors.blue,
      ),
      items: [
        DropdownMenuItem(
          value: PetEnum.all,
          child: Text('All', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
        DropdownMenuItem(
          value: PetEnum.dog,
          child: Text('Dog', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
        DropdownMenuItem(
          value: PetEnum.cat,
          child: Text('Cat', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
        DropdownMenuItem(
          value: PetEnum.parrot,
          child: Text('Parrot', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
        DropdownMenuItem(
          value: PetEnum.monkey,
          child: Text('Monkey', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
        DropdownMenuItem(
          value: PetEnum.turtle,
          child: Text('Turtle', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
      ],
    );
  }
}
