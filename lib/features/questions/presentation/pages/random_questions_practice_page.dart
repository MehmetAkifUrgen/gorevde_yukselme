import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/ad_providers.dart';
import '../../../../core/services/admob_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/premium_features_service.dart';
import '../widgets/question_card.dart';

class RandomQuestionsPracticePage extends ConsumerStatefulWidget {
  final List<Question> questions;
  final int? questionCount;
  final String? title;
  final bool isMiniQuestions;

  const RandomQuestionsPracticePage({
    super.key,
    required this.questions,
    this.questionCount,
    this.title,
    this.isMiniQuestions = false,
  });

  @override
  ConsumerState<RandomQuestionsPracticePage> createState() => _RandomQuestionsPracticePageState();
}

class _RandomQuestionsPracticePageState extends ConsumerState<RandomQuestionsPracticePage> {
  late List<Question> _allQuestions;
  late List<Question> _availableQuestions;
  Question? _currentQuestion;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  int _targetQuestionCount = 0;
  int? _selectedAnswerIndex;
  final Set<String> _answeredQuestionIds = <String>{};
  final PremiumFeaturesService _premiumService = PremiumFeaturesService();
  
  // Review mode state
  final List<Question> _history = <Question>[]; // answered questions in order
  final Map<String, int> _selectionMap = <String, int>{}; // questionId -> selected index
  bool _viewOnly = false;
  int? _historyCursor; // null => live mode, otherwise index into _history
  
  // Timer variables for mini questions
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializePracticeSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializePracticeSession() {
    _targetQuestionCount = widget.questionCount ?? 20;
    _allQuestions = List<Question>.from(widget.questions);
    _availableQuestions = List<Question>.from(_allQuestions);
    _availableQuestions.shuffle(Random());
    
    _correctAnswers = 0;
    _totalAnswered = 0;
    _answeredQuestionIds.clear();
    
    // Reset question counter for ads
    if (widget.isMiniQuestions) {
      ref.read(miniQuestionsCounterProvider.notifier).reset();
    } else {
      ref.read(questionCounterProvider.notifier).reset();
    }
    
    // Select first question
    _selectNextQuestion();
    
    // Start timer for mini questions
    if (widget.isMiniQuestions) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _selectNextQuestion() {
    if (_availableQuestions.isEmpty) {
      // No more questions available, complete session
      _completeSession();
      return;
    }
    
    // Select random question from available questions
    final random = Random();
    final randomIndex = random.nextInt(_availableQuestions.length);
    _currentQuestion = _availableQuestions[randomIndex];
    
    // Remove selected question from available questions to prevent repetition
    _availableQuestions.removeAt(randomIndex);
    
    setState(() {
      _selectedAnswerIndex = null;
      _viewOnly = false;
      _historyCursor = null;
    });
  }

  void _handleQuestionAnswered(int selectedIndex) {
    if (_currentQuestion == null) return;
    
    final currentQuestion = _currentQuestion!;
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;
    
    // Seçilen cevap indeksini ayarla
    setState(() {
      _selectedAnswerIndex = selectedIndex;
    });
    
    // Check if user can ask questions
    if (!_premiumService.canAskQuestion()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_premiumService.getRestrictionMessage('questions')),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Record question asked for limit tracking
    _premiumService.recordQuestionAsked();
    
    // Update statistics
    if (!_answeredQuestionIds.contains(currentQuestion.id)) {
      _answeredQuestionIds.add(currentQuestion.id);
      _totalAnswered++;
      if (isCorrect) {
        _correctAnswers++;
      }
      
      // Update global question statistics
      ref.read(questionsProvider.notifier).updateQuestionStats(
        currentQuestion.id,
        isCorrect,
      );
      
        // Update local statistics (her zaman local storage kullan)
        final firebaseUser = ref.read(currentFirebaseUserProvider);
        final userId = firebaseUser?.uid ?? ''; // Guest için boş string
        final localStats = ref.read(localStatisticsServiceProvider);
        print('[RandomQuestionsPracticePage] Saving answer - UserId: $userId, IsCorrect: $isCorrect');
        
        // Detaylı istatistik kaydet
        localStats.incrementQuestion(
          userId: userId, 
          isCorrect: isCorrect,
          subject: currentQuestion.subject,
          profession: currentQuestion.targetProfessions.isNotEmpty ? currentQuestion.targetProfessions.first.name : null,
          ministry: currentQuestion.ministry,
          isRandomQuestion: true, // Bu random question
        );
        print('[RandomQuestionsPracticePage] Answer saved successfully');
    }

    // Save to history for review
    _selectionMap[currentQuestion.id] = selectedIndex;
    _history.add(currentQuestion);

    // Show feedback
    _showAnswerFeedback(isCorrect, currentQuestion);
  }

  void _showAnswerFeedback(bool isCorrect, Question question) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? 'Doğru!' : 'Yanlış!',
              style: TextStyle(
                color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCorrect) ...[
              const Text(
                'Doğru cevap:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                question.options[question.correctAnswerIndex],
                style: const TextStyle(color: AppTheme.successGreen),
              ),
              const SizedBox(height: 12),
            ],
            if (question.explanation.isNotEmpty) ...[
              const Text(
                'Açıklama:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(question.explanation),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _goToNextQuestion, // Sonraki soruya geç
            child: Text(
              _totalAnswered < _targetQuestionCount 
                  ? 'Sonraki Soru' 
                  : 'Sonuçları Gör',
              style: const TextStyle(color: AppTheme.primaryNavyBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextQuestion() {
    // Eğer dialog açıksa kapat, değilse devam et
    if (ModalRoute.of(context)?.isCurrent == false) {
      Navigator.of(context).pop(); // Close feedback dialog if open
    }
    
    // Increment question counter
    if (widget.isMiniQuestions) {
      ref.read(miniQuestionsCounterProvider.notifier).increment();
      // Mini sorular için sadece 5. sorudan sonra reklam
      final miniCounter = ref.read(miniQuestionsCounterProvider);
      if (miniCounter == 5) {
        // 5. sorudan sonra reklam göster
        ref.read(adDisplayProvider.notifier).forceShowAd(AdPlacement.aiPractice);
      }
    } else {
      ref.read(questionCounterProvider.notifier).increment();
      // Soruları Karıştır için her 4 soruda bir reklam
      ref.read(adDisplayProvider.notifier).showAdEvery4Questions();
    }
    
    // Check if we've reached target question count
    if (_totalAnswered >= _targetQuestionCount) {
      _completeSession();
    } else {
      // Select next question (no repetition)
      _selectNextQuestion();
    }
  }

  void _completeSession() async {
    // Stop timer for mini questions
    if (widget.isMiniQuestions) {
      _stopTimer();
      
      final firebaseUser = ref.read(currentFirebaseUserProvider);
      final userId = firebaseUser?.uid ?? '';
      final localStats = ref.read(localStatisticsServiceProvider);
      
      // Mini sorular için süre kaydet (gerçek süre + 3 dakika)
      final realTimeMinutes = (_elapsedSeconds / 60).round();
      final miniQuestionsTime = realTimeMinutes + 3;
      localStats.addStudyTimeMinutes(userId: userId, minutes: miniQuestionsTime);
      
      // Mini sorular sayısını artır
      localStats.incrementMiniQuestionsCompleted(userId: userId, count: _totalAnswered);
      
      print('[RandomQuestionsPracticePage] Mini questions completed - UserId: $userId, Questions: $_totalAnswered, Real time: ${_formatTime(_elapsedSeconds)}, Saved time: $miniQuestionsTime minutes');
    }
    
    // Show final ad before showing results
    final placement = widget.isMiniQuestions ? AdPlacement.aiPractice : AdPlacement.randomPractice;
    await ref.read(adDisplayProvider.notifier).forceShowAd(placement);
    
    // Show results after ad
    _showSessionResults();
  }

  void _showSessionResults() {
    final accuracy = _totalAnswered > 0 ? (_correctAnswers / _totalAnswered * 100) : 0.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Oturum Tamamlandı!',
          style: TextStyle(
            color: AppTheme.primaryNavyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam Soru:'),
                      Text(
                        '$_totalAnswered',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Doğru Cevap:'),
                      Text(
                        '$_correctAnswers',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Yanlış Cevap:'),
                      Text(
                        '${_totalAnswered - _correctAnswers}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Başarı Oranı:'),
                      Text(
                        '${accuracy.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accuracy >= 70 ? AppTheme.successGreen : AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                  // Show time for mini questions
                  if (widget.isMiniQuestions) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Geçen Süre:'),
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavyBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartSession();
            },
            child: const Text(
              'Tekrar Başla',
              style: TextStyle(color: AppTheme.primaryNavyBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavyBlue,
              foregroundColor: AppTheme.secondaryWhite,
            ),
            child: const Text('Bitir'),
          ),
        ],
      ),
    );
  }

  void _restartSession() {
    setState(() {
      _initializePracticeSession();
    });
  }

  void _showPreviousInHistory() {
    if (_history.isEmpty) return;
    setState(() {
      // If not yet in history mode, jump appropriately:
      // - If the last answered is the current question, go to one before it (if available)
      // - Otherwise, go to last answered
      if (_historyCursor == null) {
        int target = _history.length - 1;
        if (_currentQuestion != null && _history.isNotEmpty && _history.last.id == _currentQuestion!.id) {
          target = _history.length - 2; // skip current just-answered
        }
        if (target < 0) target = 0;
        _historyCursor = target;
      } else if (_historyCursor! > 0) {
        _historyCursor = _historyCursor! - 1;
      }
      final q = _history[_historyCursor!];
      _currentQuestion = q;
      _selectedAnswerIndex = _selectionMap[q.id];
      _viewOnly = true;
    });
  }

  void _shuffleQuestions() {
    // Reset available questions with all questions
    _availableQuestions = List<Question>.from(_allQuestions);
    _availableQuestions.shuffle(Random());
    
    // Remove already answered questions from available questions
    _availableQuestions.removeWhere((question) => _answeredQuestionIds.contains(question.id));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kalan sorular karıştırıldı!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exitSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isMiniQuestions ? 'AI Destekli Oturumu Kapat' : 'Oturumdan Çık'),
        content: Text(
          widget.isMiniQuestions
              ? 'Cevapladığınız sorular istatistiklerinize kaydedildi. Bu oturumu kapatırsanız kalan sorulara daha sonra yeniden başlamanız gerekir.'
              : 'Cevapladığınız sorular istatistiklerinize kaydedildi. Oturumdan çıkarsanız kalan soruları daha sonra yeniden başlatmanız gerekir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.secondaryWhite,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionLimitInfo() {
    // Kalan soru mesajı kaldırıldı
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? 'Rastgele Sorular',
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppTheme.primaryNavyBlue,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = _currentQuestion!;
    final fontSize = ref.watch(fontSizeProvider);
    final progress = _totalAnswered / _targetQuestionCount;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(
          widget.title ?? 'Rastgele Sorular',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryNavyBlue,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSession,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleQuestions,
            tooltip: 'Soruları Karıştır',
          ),
          // Timer for mini questions
          if (widget.isMiniQuestions)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryNavyBlue,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_totalAnswered}/$_targetQuestionCount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.secondaryWhite,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryNavyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.lightGrey,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNavyBlue),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Doğru: $_correctAnswers',
                      style: const TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Yanlış: ${_totalAnswered - _correctAnswers}',
                      style: const TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildQuestionLimitInfo(),
              ],
            ),
          ),
          
          // Question Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  QuestionCard(
                    question: currentQuestion,
                    fontSize: fontSize,
                    onAnswered: _handleQuestionAnswered,
                    onStarToggle: () {
                      final firebaseUser = ref.read(currentFirebaseUserProvider);
                      if (firebaseUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Favorilere eklemek için lütfen giriş yapın.')),
                        );
                        context.push(AppRouter.login);
                        return;
                      }
                      ref.read(questionsProvider.notifier).toggleQuestionStar(currentQuestion.id);
                    },
                    viewOnly: _viewOnly,
                    initialSelectedIndex: _viewOnly ? _selectedAnswerIndex : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigation buttons: Previous (history) + Next/Bitir (combined)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _history.isNotEmpty ? _showPreviousInHistory : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Önceki'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavyBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_historyCursor != null) || (_selectedAnswerIndex != null)
                              ? () {
                                  if (_historyCursor != null) {
                                    // If not at the end of history, move forward in history
                                    if (_historyCursor! < _history.length - 1) {
                                      setState(() {
                                        _historyCursor = _historyCursor! + 1;
                                        final q = _history[_historyCursor!];
                                        _currentQuestion = q;
                                        _selectedAnswerIndex = _selectionMap[q.id];
                                        _viewOnly = true;
                                      });
                                    } else {
                                      // End of history: exit to live and go to next new question
                                      setState(() {
                                        _historyCursor = null;
                                        _viewOnly = false;
                                        _selectedAnswerIndex = null;
                                      });
                                      _goToNextQuestion();
                                    }
                                  } else {
                                    _goToNextQuestion();
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            (_historyCursor == null && _totalAnswered >= _targetQuestionCount)
                                ? 'Bitir'
                                : 'Sonraki',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavyBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  const SizedBox(height: 16),
                  
                  // Banner Ad
                  // const AdMobBannerWidget(), // Removed as per user's request
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}