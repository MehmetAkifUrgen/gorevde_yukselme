import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/repositories/questions_repository.dart';
import '../../../../core/services/questions_api_service.dart';
import '../../../../core/services/favorites_service.dart';
import '../widgets/question_card.dart';
import '../widgets/font_size_slider.dart';

class StarredQuestionsPage extends ConsumerStatefulWidget {
  const StarredQuestionsPage({super.key});

  @override
  ConsumerState<StarredQuestionsPage> createState() => _StarredQuestionsPageState();
}

class _StarredQuestionsPageState extends ConsumerState<StarredQuestionsPage> {
  String? selectedCategory;
  bool isPracticeMode = false;
  List<Question> starredQuestions = [];
  int currentQuestionIndex = 0;
  
  // Answer tracking for practice mode
  Map<String, int?> answers = {}; // questionId -> selectedAnswerIndex
  Map<String, bool> isAnswered = {}; // questionId -> isAnswered
  
  // Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStarredQuestions();
  }

  void _loadStarredQuestions() async {
    final firebaseUser = ref.read(currentFirebaseUserProvider);
    final userId = firebaseUser?.uid ?? '';
    final favoritesService = ref.read(favoritesServiceProvider);
    List<Question> allQuestions = ref.read(questionsProvider);
    
    // If we have cached questions, load favorites immediately
    if (allQuestions.isNotEmpty) {
      await _loadFavoritesFromCache(allQuestions, favoritesService, userId);
    } else {
      // Show loading and fetch questions in background
      await _loadFavoritesWithAPI(favoritesService, userId);
    }
  }

  Future<void> _loadFavoritesFromCache(List<Question> allQuestions, FavoritesService favoritesService, String userId) async {
    try {
      final localIds = await favoritesService.getLocalStarredIds(userId);
      
      final localList = allQuestions.where((q) => localIds.contains(q.id)).toList();
      
      if (mounted) {
        setState(() {
          starredQuestions = localList;
          isLoading = false;
        });
      }
      
      // Sync with remote in background
      _syncWithRemoteInBackground(favoritesService, userId, allQuestions);
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFavoritesWithAPI(FavoritesService favoritesService, String userId) async {
    try {
      // Fetch questions via repository (uses cache if available)
      final prefs = ref.read(sharedPreferencesProvider);
      final repo = QuestionsRepositoryImpl(
        apiService: QuestionsApiService(),
        prefs: prefs,
      );
      
      final fetched = await repo.getAllQuestions();
      // Put into provider for reuse
      ref.read(questionsProvider.notifier).setQuestions(fetched);
      
      await _loadFavoritesFromCache(fetched, favoritesService, userId);
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _syncWithRemoteInBackground(FavoritesService favoritesService, String userId, List<Question> allQuestions) async {
    try {
      final syncedIds = await favoritesService.syncFromRemote(userId);
      
      final syncedList = allQuestions.where((q) => syncedIds.contains(q.id)).toList();
      
      if (mounted && syncedList.length != starredQuestions.length) {
        setState(() {
          starredQuestions = syncedList;
        });
      }
    } catch (e) {
      // Background sync failed, but local data is still available
    }
  }

  List<Question> get filteredQuestions {
    final filtered = starredQuestions.where((question) {
      if (selectedCategory == null) return true;
      
      // Extract category from question ID (format: Category_Profession_Subject_QuestionNo)
      final parts = question.id.split('_');
      if (parts.isNotEmpty) {
        final questionCategory = parts[0];
        return questionCategory == selectedCategory;
      }
      return false;
    }).toList();
    return filtered;
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
              // Dynamic categories from API
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(availableCategoriesProvider);
                  return categoriesAsync.when(
                    data: (categories) => Wrap(
                      spacing: 8,
                      children: categories.map((categoryName) => FilterChip(
                        label: Text(categoryName),
                        selected: selectedCategory == categoryName,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? categoryName : null;
                          });
                        },
                      )).toList(),
                    ),
                    loading: () => const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Text('Kategoriler yüklenemedi: $error'),
                  );
                },
              ),
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
      final currentQuestion = filteredQuestions[currentQuestionIndex];
      setState(() {
        answers[currentQuestion.id] = answerIndex;
        isAnswered[currentQuestion.id] = true;
      });
      
      // Check if all questions are answered
      if (_areAllQuestionsAnswered()) {
        _showCompletionDialog();
      }
    }
  }

  void _onStarToggle() {
    if (filteredQuestions.isEmpty) return;
    final q = filteredQuestions[currentQuestionIndex];
    // Require login to favorite
    final firebaseUser = ref.read(currentFirebaseUserProvider);
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorilere eklemek için lütfen giriş yapın.')),
      );
      // Navigate to login
      Navigator.of(context).pushNamed('/login');
      return;
    }
    // Optimistic: update provider and local list
    ref.read(questionsProvider.notifier).toggleQuestionStar(q.id);
    final userId = firebaseUser.uid;
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
          if (filtered.isNotEmpty && !isPracticeMode)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  isPracticeMode = true;
                  currentQuestionIndex = 0;
                });
              },
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Favori Soruları Çöz', style: TextStyle(color: Colors.white)),
            ),
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
      body: isLoading
          ? _buildLoadingState()
          : filtered.isEmpty
              ? _buildEmptyState()
              : isPracticeMode
                  ? _buildPracticeMode(filtered, fontSize)
                  : _buildListMode(filtered, fontSize),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Favori sorular yükleniyor...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Soruları Çöz'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              setState(() {
                isPracticeMode = false;
                currentQuestionIndex = 0;
                answers.clear();
                isAnswered.clear();
              });
            },
            tooltip: 'Çıkış',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Cevaplanan: ${_getAnsweredCount()} / ${questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    if (_getAnsweredCount() > 0)
                      Text(
                        'Doğru: ${_getCorrectCount()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
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
                key: ValueKey(currentQuestion.id), // Force widget rebuild when question changes
                question: currentQuestion,
                fontSize: fontSize,
                onAnswered: _onAnswered,
                onStarToggle: () {
                  // Favori sorular sayfasında favori ikonu gösterme
                },
                showStarIcon: false, // Favori ikonunu gizle
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
                if (currentQuestionIndex < questions.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      child: const Text('Sonraki'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Bitir: practice modundan çık ve liste moduna dön
                        setState(() {
                          isPracticeMode = false;
                          currentQuestionIndex = 0;
                          answers.clear();
                          isAnswered.clear();
                        });
                      },
                      child: const Text('Bitir'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
          child: _buildClickableQuestionCard(question, fontSize),
        );
      },
    );
  }

  Widget _buildClickableQuestionCard(Question question, double fontSize) {
    // Extract context info from question ID
    final parts = question.id.split('_');
    String contextInfo = '';
    if (parts.length >= 3) {
      final category = parts[0];
      final profession = parts[1];
      final subject = parts[2];
      contextInfo = '$category • $profession • $subject';
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showQuestionDialog(question, fontSize),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Context info
              if (contextInfo.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contextInfo,
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: AppTheme.primaryNavyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (contextInfo.isNotEmpty) const SizedBox(height: 8),
              
              // Question text
              Text(
                question.questionText,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Options preview
              ...question.options.take(2).map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + question.options.indexOf(option)),
                          style: TextStyle(
                            fontSize: fontSize * 0.7,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavyBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(fontSize: fontSize * 0.9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
              
              if (question.options.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '... ve ${question.options.length - 2} seçenek daha',
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Tap to view hint
              Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: fontSize * 0.8,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Detayları görmek için dokunun',
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestionDialog(Question question, double fontSize) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavyBlue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Soru Detayı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize * 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Context info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: fontSize * 0.9,
                              color: AppTheme.primaryNavyBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getContextInfo(question),
                                style: TextStyle(
                                  fontSize: fontSize * 0.9,
                                  color: AppTheme.primaryNavyBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Question text
                      Text(
                        question.questionText,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Options
                      ...question.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNavyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontSize: fontSize * 0.8,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryNavyBlue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: fontSize * 0.95,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 16),
                      
                      // Explanation - Favori sorular sayfasında açıklamayı gizle
                      // if (question.explanation.isNotEmpty) ...[
                      //   Container(
                      //     padding: const EdgeInsets.all(12),
                      //     decoration: BoxDecoration(
                      //       color: Colors.blue.withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Row(
                      //           children: [
                      //             Icon(
                      //               Icons.lightbulb_outline,
                      //               size: fontSize * 0.9,
                      //               color: Colors.blue,
                      //             ),
                      //             const SizedBox(width: 8),
                      //             Text(
                      //               'Açıklama',
                      //               style: TextStyle(
                      //                 fontSize: fontSize * 0.9,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.blue,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 8),
                      //         Text(
                      //           question.explanation,
                      //           style: TextStyle(
                      //             fontSize: fontSize * 0.9,
                      //             color: Colors.blue.shade700,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ),
              
              // Footer with star toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _onStarToggle();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Favorilerden Çıkar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              isPracticeMode = true;
                              currentQuestionIndex = filteredQuestions.indexOf(question);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_arrow, 
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Çöz', 
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getContextInfo(Question question) {
    final parts = question.id.split('_');
    if (parts.length >= 3) {
      final category = parts[0];
      final profession = parts[1];
      final subject = parts[2];
      return '$category • $profession • $subject';
    }
    return 'Konu bilgisi bulunamadı';
  }

  bool _areAllQuestionsAnswered() {
    final filtered = filteredQuestions;
    return filtered.every((question) => isAnswered[question.id] == true);
  }

  void _showCompletionDialog() {
    final filtered = filteredQuestions;
    int correctCount = 0;
    int totalCount = filtered.length;
    
    for (final question in filtered) {
      final selectedAnswer = answers[question.id];
      if (selectedAnswer != null && selectedAnswer == question.correctAnswerIndex) {
        correctCount++;
      }
    }
    
    final accuracy = totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accuracy >= 70 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  accuracy >= 70 ? Icons.celebration : Icons.school,
                  size: 40,
                  color: accuracy >= 70 ? Colors.green : Colors.orange,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Favori Sorular Tamamlandı!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Results
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultItem('Toplam', totalCount.toString(), Colors.blue),
                        _buildResultItem('Doğru', correctCount.toString(), Colors.green),
                        _buildResultItem('Yanlış', (totalCount - correctCount).toString(), Colors.red),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Accuracy
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: accuracy >= 70 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Başarı Oranı: %$accuracy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accuracy >= 70 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Motivational message
              Text(
                _getMotivationalMessage(accuracy),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          isPracticeMode = false;
                          answers.clear();
                          isAnswered.clear();
                          currentQuestionIndex = 0;
                        });
                      },
                      child: const Text('Listeye Dön'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          answers.clear();
                          isAnswered.clear();
                          currentQuestionIndex = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavyBlue,
                      ),
                      child: const Text('Tekrar Çöz', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int accuracy) {
    if (accuracy >= 90) {
      return 'Mükemmel! Çok başarılı bir performans gösterdiniz! 🎉';
    } else if (accuracy >= 80) {
      return 'Harika! Çok iyi bir sonuç elde ettiniz! 👏';
    } else if (accuracy >= 70) {
      return 'İyi iş! Başarılı bir performans gösterdiniz! 👍';
    } else if (accuracy >= 60) {
      return 'Orta seviyede bir performans. Biraz daha çalışarak gelişebilirsiniz! 💪';
    } else {
      return 'Daha fazla çalışma gerekiyor. Tekrar deneyin! 📚';
    }
  }

  int _getAnsweredCount() {
    final filtered = filteredQuestions;
    return filtered.where((question) => isAnswered[question.id] == true).length;
  }

  int _getCorrectCount() {
    final filtered = filteredQuestions;
    int correctCount = 0;
    for (final question in filtered) {
      final selectedAnswer = answers[question.id];
      if (selectedAnswer != null && selectedAnswer == question.correctAnswerIndex) {
        correctCount++;
      }
    }
    return correctCount;
  }
}