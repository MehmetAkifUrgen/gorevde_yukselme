import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/question_card.dart';
import '../widgets/font_size_slider.dart';

class StarredQuestionsPage extends ConsumerStatefulWidget {
  const StarredQuestionsPage({super.key});

  @override
  ConsumerState<StarredQuestionsPage> createState() => _StarredQuestionsPageState();
}

class _StarredQuestionsPageState extends ConsumerState<StarredQuestionsPage> {
  QuestionCategory? selectedCategory;
  QuestionDifficulty? selectedDifficulty;
  bool isPracticeMode = false;
  List<Question> starredQuestions = [];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStarredQuestions();
  }

  void _loadStarredQuestions() {
    // TODO: Load starred questions from repository
    setState(() {
      starredQuestions = [];
    });
  }

  List<Question> get filteredQuestions {
    return starredQuestions.where((question) {
      bool categoryMatch = selectedCategory == null || question.category == selectedCategory;
      bool difficultyMatch = selectedDifficulty == null || question.difficulty == selectedDifficulty;
      return categoryMatch && difficultyMatch;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Questions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // Category Filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = selected ? null : selectedCategory;
                  });
                },
              ),
              ...QuestionCategory.values.map((category) => FilterChip(
                label: Text(category.displayName),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = selected ? category : null;
                  });
                },
              )),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Difficulty Filter
          Text(
            'Difficulty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedDifficulty == null,
                onSelected: (selected) {
                  setState(() {
                    selectedDifficulty = selected ? null : selectedDifficulty;
                  });
                },
              ),
              ...QuestionDifficulty.values.map((difficulty) => FilterChip(
                label: Text(difficulty.displayName),
                selected: selectedDifficulty == difficulty,
                onSelected: (selected) {
                  setState(() {
                    selectedDifficulty = selected ? difficulty : null;
                  });
                },
              )),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePracticeMode() {
    setState(() {
      isPracticeMode = !isPracticeMode;
      currentQuestionIndex = 0;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < filteredQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _onAnswered(int answerIndex) {
    // Handle answer selection in practice mode
    if (isPracticeMode) {
      // Show immediate feedback
    }
  }

  void _onStarToggle() {
    // Handle star toggle
    setState(() {
      // Remove from starred questions
      if (filteredQuestions.isNotEmpty) {
        starredQuestions.remove(filteredQuestions[currentQuestionIndex]);
        if (currentQuestionIndex >= filteredQuestions.length && currentQuestionIndex > 0) {
          currentQuestionIndex--;
        }
      }
    });
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: const FontSizeSlider(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredQuestions;
    final fontSize = ref.watch(fontSizeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Questions'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showFontSizeDialog(context),
            tooltip: 'Font Size',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: Icon(isPracticeMode ? Icons.quiz : Icons.list),
            onPressed: _togglePracticeMode,
            tooltip: isPracticeMode ? 'List Mode' : 'Practice Mode',
          ),
        ],
      ),
      body: filtered.isEmpty
          ? _buildEmptyState()
          : isPracticeMode
              ? _buildPracticeMode(filtered, fontSize)
              : _buildListMode(filtered, fontSize),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No starred questions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Star questions while studying to save them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeMode(List<Question> questions, double fontSize) {
    final currentQuestion = questions[currentQuestionIndex];
    
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${((currentQuestionIndex + 1) / questions.length * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // Progress bar
        LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / questions.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
        ),
        
        // Question card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QuestionCard(
              question: currentQuestion,
              fontSize: fontSize,
              onAnswered: _onAnswered,
              onStarToggle: _onStarToggle,
            ),
          ),
        ),
        
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: currentQuestionIndex > 0 ? _previousQuestion : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: currentQuestionIndex < questions.length - 1 ? _nextQuestion : null,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListMode(List<Question> questions, double fontSize) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: QuestionCard(
            question: question,
            fontSize: fontSize,
            onAnswered: _onAnswered,
            onStarToggle: _onStarToggle,
          ),
        );
      },
    );
  }
}