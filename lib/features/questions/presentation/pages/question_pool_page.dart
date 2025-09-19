import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/question_card.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/font_size_slider.dart';

class QuestionPoolPage extends ConsumerStatefulWidget {
  const QuestionPoolPage({super.key});

  @override
  ConsumerState<QuestionPoolPage> createState() => _QuestionPoolPageState();
}

class _QuestionPoolPageState extends ConsumerState<QuestionPoolPage> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final user = ref.watch(userProvider);
    
    // Filter questions based on selected category and user profession
    final filteredQuestions = questions.where((question) {
      final categoryMatch = selectedCategory == null || 
          question.category == selectedCategory;
      final professionMatch = user?.profession == null ||
          question.targetProfessions.contains(user!.profession);
      return categoryMatch && professionMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Soru Havuzu'),
        backgroundColor: AppTheme.primaryNavyBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              // Shuffle questions
              ref.read(questionsProvider.notifier).shuffleQuestions();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sorular karıştırıldı'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              _showFontSizeDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.secondaryWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori Filtresi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryFilterChip(
                        label: 'Tümü',
                        isSelected: selectedCategory == null,
                        onSelected: () {
                          ref.read(selectedCategoryProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...QuestionCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryFilterChip(
                            label: category.displayName,
                            isSelected: selectedCategory == category,
                            onSelected: () {
                              ref.read(selectedCategoryProvider.notifier).state = category;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Questions Count and Random Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.lightGrey,
            child: Row(
              children: [
                Text(
                  '${filteredQuestions.length} soru bulundu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: filteredQuestions.isNotEmpty ? () {
                    _startRandomQuestions(context, filteredQuestions);
                  } : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Rastgele Başla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: AppTheme.secondaryWhite,
                  ),
                ),
              ],
            ),
          ),
          
          // Questions List
          Expanded(
            child: filteredQuestions.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = filteredQuestions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestionCard(
                          question: question,
                          fontSize: fontSize,
                          onAnswered: (selectedIndex) {
                            _handleQuestionAnswered(question, selectedIndex);
                          },
                          onStarToggle: () {
                            _toggleQuestionStar(question);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: AppTheme.darkGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu kategoride soru bulunamadı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı bir kategori seçmeyi deneyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGrey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yazı Boyutu'),
        content: const FontSizeSlider(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _startRandomQuestions(BuildContext context, List<Question> questions) {
    // TODO: Navigate to random question practice mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rastgele soru modu yakında eklenecek'),
      ),
    );
  }

  void _handleQuestionAnswered(Question question, int selectedIndex) {
    // Update question statistics
    ref.read(questionsProvider.notifier).updateQuestionStats(
      question.id,
      selectedIndex == question.correctAnswerIndex,
    );
    
    // Show feedback
    final isCorrect = selectedIndex == question.correctAnswerIndex;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? 'Doğru cevap!' : 'Yanlış cevap. Doğru cevap: ${question.options[question.correctAnswerIndex]}',
        ),
        backgroundColor: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleQuestionStar(Question question) {
    ref.read(questionsProvider.notifier).toggleQuestionStar(question.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          question.isStarred ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}