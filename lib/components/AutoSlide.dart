import 'dart:async';
import 'package:flutter/material.dart';

class AutoSlide {
  final PageController pageController;
  final List<String> slidingPetImages;
  int currentPage = 0;
  Timer? _timer;

  AutoSlide({
    required this.pageController,
    required this.slidingPetImages,
  });

  void startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (currentPage < slidingPetImages.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  void nextPage() {
    if (currentPage < slidingPetImages.length - 1) {
      currentPage++;
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}
