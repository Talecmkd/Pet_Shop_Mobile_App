import 'package:flutter/material.dart';
import 'package:final_project_pet_shop/Model/enum/PetEnum.dart';

import '../Model/enum/PriceFilterEnum.dart';

class PriceFilterDropdown extends StatelessWidget {
  final PriceFilterEnum selectedPrice;
  final ValueChanged<PriceFilterEnum?> onChanged;

  PriceFilterDropdown({required this.selectedPrice, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PriceFilterEnum>(
      value: selectedPrice,
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down), // Add an arrow icon to indicate dropdown
      iconSize: 24, // Set the size of the dropdown icon
      elevation: 16, // Set the elevation of the dropdown menu
      style: TextStyle(color: Colors.blue), // Text style for dropdown items
      underline: Container( // Customize the underline
        height: 2,
        color: Colors.blue,
      ),
      items: PriceFilterEnum.values.map((PriceFilterEnum price) {
        return DropdownMenuItem<PriceFilterEnum>(
          value: price,
          child: Text(price.toString().split('.').last.replaceAll('to', 'To '), style: TextStyle(color: Colors.black)), // Text style for dropdown items
        );
      }).toList(),
    );
  }
}
