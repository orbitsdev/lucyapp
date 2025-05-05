import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';



class LocalLottieImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool repeat;

  const LocalLottieImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true, // Default repeat to true
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
      repeat: repeat, // This ensures repeat is true by default
      width: width ?? 140, // Default width
      height: height ?? 140, // Default height
      fit: fit,
    );
  }
}
