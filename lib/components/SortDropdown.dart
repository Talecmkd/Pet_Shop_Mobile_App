import 'package:flutter/material.dart';

import '../Model/enum/SortOption.dart';

class SortDropdown extends StatelessWidget {
  final SortOption selectedOption;
  final ValueChanged<SortOption?> onChanged;

  SortDropdown({required this.selectedOption, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<SortOption>(
      value: selectedOption,
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
        DropdownMenuItem<SortOption>(
          value: SortOption.priceDescending,
          child: Text('Price - Highest to Lowest', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.priceAscending,
          child: Text('Price - Lowest to Highest', style: TextStyle(color: Colors.black)), // Text style for dropdown items
        ),
      ],
    );
  }
}
