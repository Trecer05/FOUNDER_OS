import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    required this.logoId,
    this.size = 44,
    this.borderRadius = 14,
    super.key,
  });

  final String logoId;
  final double size;
  final double borderRadius;

  static String assetFor(String logoId) {
    final normalized = RegExp(r'^company_logo_(\d{2})$').hasMatch(logoId)
        ? logoId
        : 'company_logo_01';
    return 'assets/company_logos/$normalized.png';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Image.asset(
            assetFor(logoId),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.apartment_rounded, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}
