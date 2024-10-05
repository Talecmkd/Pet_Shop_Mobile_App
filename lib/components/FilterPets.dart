import 'package:final_project_pet_shop/Model/enum/PetEnum.dart';
import '../Model/Pet.dart';
import '../Model/enum/PriceFilterEnum.dart';


class FilterPets {
  static List<Pet> filterByType(List<Pet> pets, PetEnum type) {
    return pets.where((pet) => pet.pet_type == type.name).toList();
  }

  static List<Pet> filterByPrice(List<Pet> pets, PriceFilterEnum priceFilter) {
    if (priceFilter == PriceFilterEnum.toAdopt) {
      return pets.where((pet) => pet.price == 0).toList();
    } else if (priceFilter == PriceFilterEnum.toBuy) {
      return pets.where((pet) => pet.price > 0).toList();
    }
    return pets;
  }

  static List<Pet> filterByTypeAndPrice(List<Pet> pets, PetEnum type, PriceFilterEnum priceFilter) {
    List<Pet> filteredPets = pets;
    if (type != PetEnum.all) {
      filteredPets = filterByType(filteredPets, type);
    }
    filteredPets = filterByPrice(filteredPets, priceFilter);
    return filteredPets;
  }
  static void sortByPriceDescending(List<Pet> pets) {
    pets.sort((a, b) => b.price.compareTo(a.price));
  }

  // Sort pets by price from lowest to highest
  static void sortByPriceAscending(List<Pet> pets) {
    pets.sort((a, b) => a.price.compareTo(b.price));
  }
}
