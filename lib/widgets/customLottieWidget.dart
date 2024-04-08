import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottieWidget extends StatelessWidget {
  final String path;
  const CustomLottieWidget({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/lottie/$path.json', repeat: true);
  }
}
