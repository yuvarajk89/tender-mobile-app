import 'package:flutter/material.dart';

/// The Donda Export mark (enhanced from the original `donda_export.webp`).
///
/// The logo's centre diamond is fine black line-art, so on a dark surface it
/// would vanish. [onLight] renders it on a white rounded chip so the whole mark
/// stays legible on ANY background (dark login, terminal, etc.). Pass
/// `onLight: false` where the surface is already light.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64, this.onLight = true});

  final double size;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/logo/donda_logo.png',
      width: size * 0.84,
      height: size * 0.84,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
    if (!onLight) {
      return SizedBox(width: size, height: size, child: Center(child: img));
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Center(child: img),
    );
  }
}
