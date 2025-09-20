import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';
import '../services/category_service.dart';

/// Widget that displays category name dynamically from API
class CategoryDisplayWidget extends ConsumerWidget {
  final QuestionCategory category;
  final TextStyle? style;
  final String fallbackText;
  
  const CategoryDisplayWidget({
    super.key,
    required this.category,
    this.style,
    this.fallbackText = 'Kategori',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Convert enum to string key for API lookup
    final categoryKey = _getCategoryKey(category);
    final displayNameAsync = ref.watch(categoryDisplayNameProvider(categoryKey));
    
    return displayNameAsync.when(
      data: (displayName) => Text(
        displayName,
        style: style,
      ),
      loading: () => Text(
        fallbackText,
        style: style?.copyWith(color: Colors.grey),
      ),
      error: (_, __) => Text(
        fallbackText,
        style: style?.copyWith(color: Colors.red),
      ),
    );
  }
  
  /// Convert QuestionCategory enum to API category key
  String _getCategoryKey(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.electricalElectronics:
        return 'Elektrik-Elektronik';
      case QuestionCategory.construction:
        return 'İnşaat';
      case QuestionCategory.computerTechnology:
        return 'Bilgisayar Teknolojisi';
      case QuestionCategory.machineTechnology:
        return 'Makine Teknolojisi';
      case QuestionCategory.generalRegulations:
        return 'Genel Mevzuat';
      case QuestionCategory.programmingLanguages:
        return 'Programlama Dilleri';
    }
  }
}

/// Simple text widget for category display (for non-Consumer widgets)
class CategoryDisplayText extends StatelessWidget {
  final QuestionCategory category;
  final TextStyle? style;
  
  const CategoryDisplayText({
    super.key,
    required this.category,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryDisplayWidget(
      category: category,
      style: style,
    );
  }
}