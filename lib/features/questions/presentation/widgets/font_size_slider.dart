import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';

class FontSizeSlider extends ConsumerWidget {
  const FontSizeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Yazı Boyutu: ${fontSize.toInt()}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Örnek metin görünümü',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: fontSize,
          min: 12.0,
          max: 24.0,
          divisions: 12,
          activeColor: AppTheme.primaryNavyBlue,
          inactiveColor: AppTheme.lightGrey,
          onChanged: (value) {
            ref.read(fontSizeProvider.notifier).state = value;
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Küçük',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey,
              ),
            ),
            Text(
              'Büyük',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}