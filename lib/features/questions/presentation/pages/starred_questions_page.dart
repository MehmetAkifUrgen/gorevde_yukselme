import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/repositories/questions_repository.dart';
import '../../../../core/services/questions_api_service.dart';
import '../widgets/question_card.dart';
import '../widgets/font_size_slider.dart';

class StarredQuestionsPage extends ConsumerStatefulWidget {
  const StarredQuestionsPage({super.key});

  @override
  ConsumerState<StarredQuestionsPage> createState() => _StarredQuestionsPageState();
}

class _StarredQuestionsPageState extends ConsumerState<StarredQuestionsPage> {
  QuestionCategory? selectedCategory;
  bool isPracticeMode = false;
  List<Question> starredQuestions = [];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStarredQuestions();
  }

  void _loadStarredQuestions() {
    final firebaseUser = ref.read(currentFirebaseUserProvider);
    final userId = firebaseUser?.uid ?? '';
    final favoritesService = ref.read(favoritesServiceProvider);
    List<Question> allQuestions = ref.read(questionsProvider);
    // ignore: avoid_print
    print('[StarredPage] Loading starred for userId=$userId, allQuestions=${allQuestions.length}');
    Future<List<Question>> ensureQuestionsLoaded() async {
      if (allQuestions.isNotEmpty) return allQuestions;
      // Fallback: fetch questions via repository (uses cache if available)
      try {
        final prefs = ref.read(sharedPreferencesProvider);
        final repo = QuestionsRepositoryImpl(
          apiService: QuestionsApiService(),
          prefs: prefs,
        );
        final fetched = await repo.getAllQuestions();
        // Put into provider for reuse
        ref.read(questionsProvider.notifier).setQuestions(fetched);
        allQuestions = fetched;
        // ignore: avoid_print
        print('[StarredPage] Loaded questions via repository: ${fetched.length}');
        return fetched;
      } catch (e) {
        // ignore: avoid_print
        print('[StarredPage] Failed to load questions: $e');
        return allQuestions;
      }
    }

    favoritesService.getLocalStarredIds(userId).then((ids) async {
      // ignore: avoid_print
      print('[StarredPage] Local ids loaded: ${ids.length}');
      final questions = await ensureQuestionsLoaded();
      final byId = questions.where((q) => ids.contains(q.id)).toList();
      if (mounted) {
        setState(() {
          starredQuestions = byId;
        });
      }
      // Try remote sync and refresh if differs
      favoritesService.syncFromRemote(userId).then((remoteIds) async {
        // ignore: avoid_print
        print('[StarredPage] Remote ids loaded: ${remoteIds.length}');
        if (!mounted) return;
        final questions2 = await ensureQuestionsLoaded();
        final remoteList = questions2.where((q) => remoteIds.contains(q.id)).toList();
        setState(() {
          starredQuestions = remoteList;
        });
      });
    });
  }

  List<Question> get filteredQuestions {
    return starredQuestions.where((question) {
      bool categoryMatch = selectedCategory == null || question.category == selectedCategory;
      return categoryMatch;
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
            'Soruları Filtrele',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // Category Filter
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Tümü'),
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
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Filtreleri Uygula'),
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
    if (filteredQuestions.isEmpty) return;
    final q = filteredQuestions[currentQuestionIndex];
    // Optimistic: update provider and local list
    ref.read(questionsProvider.notifier).toggleQuestionStar(q.id);
    final firebaseUser = ref.read(currentFirebaseUserProvider);
    final userId = firebaseUser?.uid ?? '';
    final favoritesService = ref.read(favoritesServiceProvider);
    final newIsStarred = !q.isStarred;
    favoritesService.setStarStatus(userId: userId, questionId: q.id, isStarred: newIsStarred);
    setState(() {
      if (!newIsStarred) {
        starredQuestions.removeWhere((e) => e.id == q.id);
        if (currentQuestionIndex >= filteredQuestions.length && currentQuestionIndex > 0) {
          currentQuestionIndex--;
        }
      } else {
        // ensure present
        if (!starredQuestions.any((e) => e.id == q.id)) {
          starredQuestions.add(q.copyWith(isStarred: true));
        }
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final filtered = filteredQuestions;
    final fontSize = ref.watch(fontSizeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Sorular'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showFontSizeDialog(context),
            tooltip: 'Yazı Boyutu',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: Icon(isPracticeMode ? Icons.quiz : Icons.list),
            onPressed: _togglePracticeMode,
            tooltip: isPracticeMode ? 'Liste Modu' : 'Alıştırma Modu',
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
            'Favori soru yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çalışırken yıldızladığınız sorular burada görünecek',
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
                'Soru ${currentQuestionIndex + 1} / ${questions.length}',
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
          child: SingleChildScrollView(
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
                  child: const Text('Önceki'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: currentQuestionIndex < questions.length - 1 ? _nextQuestion : null,
                  child: const Text('Sonraki'),
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