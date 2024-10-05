import 'package:flutter/material.dart';
import 'package:final_project_pet_shop/Model/enum/PetEnum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_pet_shop/components/PetFilterDropdown.dart';
import 'package:final_project_pet_shop/components/PetDisplayWidget.dart';
import '../Model/Pet.dart';
import '../Model/enum/PriceFilterEnum.dart';
import '../Model/enum/SortOption.dart';
import '../components/AutoSlide.dart';
import '../components/FilterPets.dart';
import '../components/PriceFilterDropdown.dart';
import '../components/SideBar.dart';
import '../components/SortDropdown.dart';

class BuyerPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  BuyerPage({required this.user});

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  final PageController _pageController = PageController();
  late final AutoSlide _autoSlide;
   List<String> _slidingPetImages =[];
  List<Pet> _pets = [];
  List<Pet> _filteredPets = [];
  int _currentPage = 0;
  PetEnum _selectedType = PetEnum.all;
  PriceFilterEnum _selectedPrice = PriceFilterEnum.all;
  SortOption _selectedSortOption = SortOption.priceDescending; // Initialize with default sorting option

  @override
  void initState() {
    super.initState();
    _autoSlide = AutoSlide(
      pageController: _pageController,
      slidingPetImages: _slidingPetImages,
    );
    _autoSlide.startAutoSlide();
    _fetchPetsFromFirebase();
  }

  @override
  void dispose() {
    _autoSlide.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchPetsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('pets').get();
      List<Pet> pets = querySnapshot.docs.map((doc) => Pet.fromFirebase(doc.data() as Map<String, dynamic>)).toList();
      setState(() {
        _pets = pets;
        _filteredPets = pets;
        _slidingPetImages=pets.take(3).map((e) => e.imagePath).toList();

      });
    } catch (error) {
      print('Error fetching pets from Firebase: $error');
    }
  }

  void _applyFilter(PetEnum? selectedType, PriceFilterEnum? selectedPrice) {
    setState(() {
      if (selectedType != null) _selectedType = selectedType;
      if (selectedPrice != null) _selectedPrice = selectedPrice;
      _filteredPets = FilterPets.filterByTypeAndPrice(_pets, _selectedType, _selectedPrice);
      _applySorting(); // Apply sorting after filtering
    });
  }

  void _applySorting() {
    if (_selectedSortOption == SortOption.priceDescending) {
      FilterPets.sortByPriceDescending(_filteredPets);
    } else {
      FilterPets.sortByPriceAscending(_filteredPets);
    }
  }

  void _nextPage() {
    setState(() {
      if (_currentPage < _slidingPetImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
    });
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      } else {
        _currentPage = _slidingPetImages.length - 1;
      }
    });
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Shop'),
        actions: [
          PetFilterDropdown(
            selectedType: _selectedType,
            onChanged: (newType) => _applyFilter(newType, _selectedPrice),
          ),
          PriceFilterDropdown(
            selectedPrice: _selectedPrice,
            onChanged: (newPrice) {
              if (newPrice != null) {
                _applyFilter(_selectedType, newPrice);
              }
            },
          ),
          SizedBox(width: 10), // Add spacing between dropdowns
          SortDropdown(
            selectedOption: _selectedSortOption,
            onChanged: (newOption) {
              setState(() {
                _selectedSortOption = newOption!;
                _applySorting(); // Apply sorting when a new option is selected
              });
            },
          ),
        ],
      ),
      drawer: SideBar(user: widget.user, onAddPetPressed: () { },),
      body: _filteredPets.isEmpty
          ? PetDisplayWidget(
          pageController: _pageController,
          slidingPetImages: _slidingPetImages,
          pets: _pets,
          currentPage: _currentPage,
          previousPage: _previousPage,
          nextPage: _nextPage,
          user: widget.user)
          : PetDisplayWidget(
        pageController: _pageController,
        slidingPetImages: _slidingPetImages,
        pets: _filteredPets,
        currentPage: _currentPage,
        previousPage: _previousPage,
        nextPage: _nextPage,
        user: widget.user,
      ),
    );
  }
}
