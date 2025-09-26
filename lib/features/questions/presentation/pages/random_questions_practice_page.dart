import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/premium_features_service.dart';
import '../widgets/question_card.dart';

class RandomQuestionsPracticePage extends ConsumerStatefulWidget {
  final List<Question> questions;
  final int? questionCount;

  const RandomQuestionsPracticePage({
    super.key,
    required this.questions,
    this.questionCount,
  });

  @override
  ConsumerState<RandomQuestionsPracticePage> createState() => _RandomQuestionsPracticePageState();
}

class _RandomQuestionsPracticePageState extends ConsumerState<RandomQuestionsPracticePage> {
  late List<Question> _practiceQuestions;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  final Set<String> _answeredQuestionIds = <String>{};
  final PremiumFeaturesService _premiumService = PremiumFeaturesService();

  @override
  void initState() {
    super.initState();
    _initializePracticeSession();
  }

  void _initializePracticeSession() {
    final questionCount = widget.questionCount ?? 20;
    final shuffledQuestions = List<Question>.from(widget.questions)..shuffle(Random());
    
    _practiceQuestions = shuffledQuestions.take(questionCount).toList();
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _totalAnswered = 0;
    _answeredQuestionIds.clear();
  }

  void _handleQuestionAnswered(int selectedIndex) {
    final currentQuestion = _practiceQuestions[_currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;
    
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
    }

    // Show feedback
    _showAnswerFeedback(isCorrect, currentQuestion);
  }

  void _showAnswerFeedback(bool isCorrect, Question question) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            onPressed: _goToNextQuestion,
            child: Text(
              _currentQuestionIndex < _practiceQuestions.length - 1 
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
    Navigator.of(context).pop(); // Close feedback dialog
    
    if (_currentQuestionIndex < _practiceQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
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

  void _shuffleQuestions() {
    setState(() {
      // Mevcut soruları karıştır
      _practiceQuestions.shuffle();
      // İlk soruya dön
      _currentQuestionIndex = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sorular karıştırıldı!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exitSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oturumdan Çık'),
        content: const Text('Oturumdan çıkmak istediğinizden emin misiniz? İlerlemeniz kaydedilmeyecek.'),
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
    final user = ref.watch(userProvider);
    final isPremium = user?.isPremium ?? false;
    
    if (isPremium) {
      return const SizedBox.shrink();
    }

    final remainingQuestions = _premiumService.getRemainingQuestions();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: remainingQuestions > 0 ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: remainingQuestions > 0 ? Colors.blue.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            remainingQuestions > 0 ? Icons.quiz : Icons.warning,
            size: 14,
            color: remainingQuestions > 0 ? Colors.blue : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            'Kalan: $remainingQuestions soru',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: remainingQuestions > 0 ? Colors.blue : Colors.orange,
            ),
          ),
          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_practiceQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rastgele Sorular'),
          backgroundColor: AppTheme.primaryNavyBlue,
        ),
        body: const Center(
          child: Text('Uygun soru bulunamadı.'),
        ),
      );
    }

    final currentQuestion = _practiceQuestions[_currentQuestionIndex];
    final fontSize = ref.watch(fontSizeProvider);
    final progress = (_currentQuestionIndex + 1) / _practiceQuestions.length;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Rastgele Sorular'),
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${_practiceQuestions.length}',
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
              child: QuestionCard(
                question: currentQuestion,
                fontSize: fontSize,
                onAnswered: _handleQuestionAnswered,
                onStarToggle: () {
                  ref.read(questionsProvider.notifier).toggleQuestionStar(currentQuestion.id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}