import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/exam_model.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/providers/ad_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../widgets/exam_timer_widget.dart';
import '../widgets/exam_progress_bar.dart';
import '../widgets/exam_question_card.dart';
import '../widgets/exam_results_modal.dart';
import '../widgets/solution_popup.dart';
import 'package:gorevde_yukselme/features/questions/presentation/widgets/font_size_slider.dart';
import '../../../../core/providers/auth_providers.dart';

class ExamSimulationPage extends ConsumerStatefulWidget {
  // Exam mode (fullExam, miniExam, practiceMode) - fallback to miniExam if not provided
  final ExamType? examType;
  // Legacy optional filter (kept for backward compatibility)
  final String? professionFilter;
  
  // New route-based filters
  final String? routeExamType; // slug like 'gorevde-yukselme' or 'unvan-degisikligi'
  final String? category;
  final String? profession;
  final String? subject;

  const ExamSimulationPage({
    super.key,
    this.examType,
    this.professionFilter,
    this.routeExamType,
    this.category,
    this.profession,
    this.subject,
  });

  @override
  ConsumerState<ExamSimulationPage> createState() => _ExamSimulationPageState();
}

class _ExamSimulationPageState extends ConsumerState<ExamSimulationPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int? _selectedAnswerIndex;
  bool _showResults = false;
  bool _showAnswerFeedback = false;
  final Set<String> _starredIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeExam();
      _initializeAdMob();
    });
  }

  Future<void> _initializeAdMob() async {
    try {
      print('[ExamSimulationPage] Attempting to initialize AdMob...');
      final adMobService = ref.read(adMobServiceProvider);
      
      print('[ExamSimulationPage] Loading interstitial ad...');
      await adMobService.loadInterstitialAd();
      print('[ExamSimulationPage] Interstitial ad loaded');
    } catch (e) {
      print('[ExamSimulationPage] AdMob initialization failed: $e');
      print('[ExamSimulationPage] Error type: ${e.runtimeType}');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    
    // Save study time when exiting without completion (her zaman local storage kullan)
    final exam = ref.read(currentExamProvider);
    if (exam != null && exam.status == ExamStatus.inProgress) {
      final firebaseUser = ref.read(currentFirebaseUserProvider);
      final userId = firebaseUser?.uid ?? ''; // Guest için boş string
      final localStats = ref.read(localStatisticsServiceProvider);
      
      // Calculate elapsed time
      final int totalSeconds = exam.durationInMinutes * 60;
      final int elapsed = totalSeconds > 0 ? (totalSeconds - _remainingSeconds) : 0;
      final int minutes = (elapsed / 60).round();
      
      if (minutes > 0) {
        localStats.addStudyTimeMinutes(userId: userId, minutes: minutes);
        print('[ExamSimulationPage] Study time saved on dispose: $minutes minutes');
      }
    }
    
    super.dispose();
  }

  Future<void> _initializeExam() async {
    final ExamType mode = widget.examType ?? ExamType.miniExam;
    try {
      List<Question> questions;
      if (widget.category != null && widget.profession != null && widget.subject != null) {
        // URL decode the parameters with error handling
        String decodedCategory; // ministry
        String decodedProfession;
        String decodedSubject;
        String decodedRouteExamType; // top-level category
        
        try {
          decodedRouteExamType = Uri.decodeComponent(widget.routeExamType ?? '');
        } catch (e) {
          try {
            String fixedRouteExamType = (widget.routeExamType ?? '')
                .replaceAll('%C4%B1', 'ı')
                .replaceAll('%C3%BC', 'ü')
                .replaceAll('%C3%B6', 'ö')
                .replaceAll('%C3%A7', 'ç')
                .replaceAll('%C4%9F', 'ğ')
                .replaceAll('%C5%9F', 'ş')
                .replaceAll('%C3%96', 'Ö')
                .replaceAll('%C3%9C', 'Ü')
                .replaceAll('%C3%87', 'Ç')
                .replaceAll('%C4%B0', 'İ')
                .replaceAll('%C4%9E', 'Ğ')
                .replaceAll('%C5%9E', 'Ş');
            decodedRouteExamType = Uri.decodeComponent(fixedRouteExamType);
          } catch (e2) {
            decodedRouteExamType = widget.routeExamType ?? '';
            print('Exam - routeExamType URI decode error: $e');
          }
        }
        
        try {
          decodedCategory = Uri.decodeComponent(widget.category!);
        } catch (e) {
          try {
            String fixedCategory = widget.category!
                .replaceAll('%C4%B1', 'ı')
                .replaceAll('%C3%BC', 'ü')
                .replaceAll('%C3%B6', 'ö')
                .replaceAll('%C3%A7', 'ç')
                .replaceAll('%C4%9F', 'ğ')
                .replaceAll('%C5%9F', 'ş')
                .replaceAll('%C3%96', 'Ö')
                .replaceAll('%C3%9C', 'Ü')
                .replaceAll('%C3%87', 'Ç')
                .replaceAll('%C4%B0', 'İ')
                .replaceAll('%C4%9E', 'Ğ')
                .replaceAll('%C5%9E', 'Ş');
            decodedCategory = Uri.decodeComponent(fixedCategory);
          } catch (e2) {
            decodedCategory = widget.category!;
            print('Exam - Category URI decode error: $e');
          }
        }
        
        try {
          decodedProfession = Uri.decodeComponent(widget.profession!);
        } catch (e) {
          try {
            String fixedProfession = widget.profession!
                .replaceAll('%C4%B1', 'ı')
                .replaceAll('%C3%BC', 'ü')
                .replaceAll('%C3%B6', 'ö')
                .replaceAll('%C3%A7', 'ç')
                .replaceAll('%C4%9F', 'ğ')
                .replaceAll('%C5%9F', 'ş')
                .replaceAll('%C3%96', 'Ö')
                .replaceAll('%C3%9C', 'Ü')
                .replaceAll('%C3%87', 'Ç')
                .replaceAll('%C4%B0', 'İ')
                .replaceAll('%C4%9E', 'Ğ')
                .replaceAll('%C5%9E', 'Ş');
            decodedProfession = Uri.decodeComponent(fixedProfession);
          } catch (e2) {
            decodedProfession = widget.profession!;
            print('Exam - Profession URI decode error: $e');
          }
        }
        
        try {
          decodedSubject = Uri.decodeComponent(widget.subject!);
        } catch (e) {
          try {
            String fixedSubject = widget.subject!
                .replaceAll('%C4%B1', 'ı')
                .replaceAll('%C3%BC', 'ü')
                .replaceAll('%C3%B6', 'ö')
                .replaceAll('%C3%A7', 'ç')
                .replaceAll('%C4%9F', 'ğ')
                .replaceAll('%C5%9F', 'ş')
                .replaceAll('%C3%96', 'Ö')
                .replaceAll('%C3%9C', 'Ü')
                .replaceAll('%C3%87', 'Ç')
                .replaceAll('%C4%B0', 'İ')
                .replaceAll('%C4%9E', 'Ğ')
                .replaceAll('%C5%9E', 'Ş');
            decodedSubject = Uri.decodeComponent(fixedSubject);
          } catch (e2) {
            decodedSubject = widget.subject!;
            print('Exam - Subject URI decode error: $e');
          }
        }
        
        print('Exam - Original routeExamType: ${widget.routeExamType}');
        print('Exam - Decoded routeExamType (category): $decodedRouteExamType');
        print('Exam - Original category (ministry): ${widget.category}');
        print('Exam - Decoded category (ministry): $decodedCategory');
        print('Exam - Original profession: ${widget.profession}');
        print('Exam - Decoded profession: $decodedProfession');
        print('Exam - Original subject: ${widget.subject}');
        print('Exam - Decoded subject: $decodedSubject');
        
        // NOTE:
        // Data hierarchy: Category (exam type) > Ministry > Profession > Subject
        // URL structure: /exam/category/ministry/profession/subject
        // API mapping:
        // - category should use routeExamType (top-level category)
        // - ministry should use category (ministry)
        // - profession should use profession (actual profession)
        // - subject should use subject
        final List<Question> filtered = await ref
            .read(
              questionsByCategoryMinistryProfessionAndSubjectProvider((
                category: decodedRouteExamType,
                ministry: decodedCategory,
                profession: decodedProfession,
                subject: decodedSubject,
              )).future,
            );
        
        print('Exam - Filtered questions count: ${filtered.length}');
        print('Exam - First few questions: ${filtered.take(3).map((q) => q.questionText.substring(0, 50)).toList()}');
        
        if (filtered.isEmpty) {
          print('Exam - No questions found for category: $decodedRouteExamType, profession: $decodedCategory, subject: $decodedSubject');
          _showErrorDialog('Sorular yüklenemedi. Lütfen tekrar deneyin.');
          return;
        }
        // Tüm soruları kullan, kısıtlama yok
        final List<Question> shuffled = List<Question>.from(filtered)..shuffle();
        questions = shuffled;
      } else {
        // Tüm random soruları al (kısıtlama yok)
        final List<Question> randomQuestions = ref.read(randomQuestionsProvider(0));
        if (randomQuestions.isEmpty) {
          _showErrorDialog('Sorular yüklenemedi. Lütfen tekrar deneyin.');
          return;
        }
        questions = randomQuestions;
      }

      final Exam exam = Exam(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: widget.subject != null ? '${widget.subject} - ${mode.displayName}' : mode.displayName,
        type: mode,
        targetProfession: UserProfession.values.first, // Default profession
        questions: questions,
        durationInMinutes: mode.calculateDuration(questions.length),
        status: ExamStatus.notStarted,
      );

      ref.read(currentExamProvider.notifier).startExam(exam);
      
      // Reset wrong answer counter for new exam
      ref.read(wrongAnswerCounterProvider.notifier).reset();
      
      _remainingSeconds = mode.calculateDuration(questions.length) * 60;
      _startTimer();
      // Load starred IDs for current user to reflect star state
      final firebaseUser = ref.read(currentFirebaseUserProvider);
      final userId = firebaseUser?.uid ?? '';
      final favoritesService = ref.read(favoritesServiceProvider);
      final ids = await favoritesService.getLocalStarredIds(userId);
      if (mounted) {
        setState(() {
          _starredIds
            ..clear()
            ..addAll(ids);
        });
        // Background sync from remote
        favoritesService.syncFromRemote(userId).then((remoteIds) {
          if (mounted && remoteIds.isNotEmpty) {
            setState(() {
              _starredIds
                ..clear()
                ..addAll(remoteIds);
            });
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Sorular yüklenirken hata oluştu.');
    }
  }

  void _startTimer() {
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _completeExam();
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswerIndex = answerIndex;
    });
    
    // Automatically submit answer after selection
    _submitAnswer();
  }

  void _submitAnswer() {
    final Exam? exam = ref.read(currentExamProvider);
    if (exam == null || _selectedAnswerIndex == null) return;

    final Question currentQuestion = exam.questions[exam.currentQuestionIndex];
    final bool isCorrect = _selectedAnswerIndex == currentQuestion.correctAnswerIndex;
    
    // Handle wrong answer counter for ads
    if (!isCorrect) {
      ref.read(wrongAnswerCounterProvider.notifier).increment();
      final wrongCount = ref.read(wrongAnswerCounterProvider);
      print('[ExamSimulationPage] Wrong answer count: $wrongCount');
      print('[ExamSimulationPage] Should show ad: ${wrongCount > 0 && wrongCount % 3 == 0}');
    }
    
        // Update local statistics (her zaman local storage kullan)
        final firebaseUser = ref.read(currentFirebaseUserProvider);
        final userId = firebaseUser?.uid ?? ''; // Guest için boş string
        final localStats = ref.read(localStatisticsServiceProvider);
        print('[ExamSimulationPage] Saving answer - UserId: $userId, IsCorrect: $isCorrect');
        
        // Detaylı istatistik kaydet
        localStats.incrementQuestion(
          userId: userId, 
          isCorrect: isCorrect,
          subject: currentQuestion.subject,
          profession: currentQuestion.targetProfessions.isNotEmpty ? currentQuestion.targetProfessions.first.name : null,
          ministry: currentQuestion.ministry,
          isRandomQuestion: false, // Bu test sorusu
        );
        print('[ExamSimulationPage] Answer saved successfully');
    ref.read(currentExamProvider.notifier).answerQuestion(
      currentQuestion.id,
      _selectedAnswerIndex!,
    );

    setState(() {
      _showAnswerFeedback = true;
    });

    // Show feedback for 2 seconds, then move to next question
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showAnswerFeedback = false;
          _selectedAnswerIndex = null;
        });
        
        // Check if we should show an ad before moving to next question
        _checkAndShowAd();
      }
    });
  }

  Future<void> _checkAndShowAd() async {
    try {
      final wrongCount = ref.read(wrongAnswerCounterProvider);
      final isPremium = ref.read(isPremiumUserProvider);
      
      print('[ExamSimulationPage] Checking ad conditions...');
      print('[ExamSimulationPage] Wrong count: $wrongCount');
      print('[ExamSimulationPage] Is premium: $isPremium');
      print('[ExamSimulationPage] Should show: ${wrongCount > 0 && wrongCount % 3 == 0 && !isPremium}');
      
      if (wrongCount > 0 && wrongCount % 3 == 0 && !isPremium) {
        print('[ExamSimulationPage] Attempting to show ad...');
        final adDisplayNotifier = ref.read(adDisplayProvider.notifier);
        final shouldShowAd = await adDisplayNotifier.showAdIfNeeded();
        
        if (shouldShowAd) {
          print('[ExamSimulationPage] Ad shown successfully');
          // Reset counter after showing ad
          ref.read(wrongAnswerCounterProvider.notifier).reset();
        } else {
          print('[ExamSimulationPage] Ad not shown');
        }
      } else {
        print('[ExamSimulationPage] Ad conditions not met, skipping');
      }
    } catch (e) {
      print('[ExamSimulationPage] Error in _checkAndShowAd: $e');
    }
    
    // Move to next question regardless of ad result
    _nextQuestion();
  }

  void _nextQuestion() {
    final Exam? exam = ref.read(currentExamProvider);
    if (exam == null) return;

    if (exam.currentQuestionIndex < exam.questions.length - 1) {
      ref.read(currentExamProvider.notifier).nextQuestion();
      setState(() {
        _selectedAnswerIndex = null;
        _showAnswerFeedback = false;
      });
    } else {
      _completeExam();
    }
  }

  void _previousQuestion() {
    final Exam? exam = ref.read(currentExamProvider);
    if (exam == null) return;

    if (exam.currentQuestionIndex > 0) {
      ref.read(currentExamProvider.notifier).previousQuestion();
      setState(() {
        _selectedAnswerIndex = null;
        _showAnswerFeedback = false;
      });
    }
  }

  void _completeExam() async {
    _timer?.cancel();
    ref.read(currentExamProvider.notifier).completeExam();
    
    // Record study time and test completion locally (her zaman local storage kullan)
    final firebaseUser = ref.read(currentFirebaseUserProvider);
    final userId = firebaseUser?.uid ?? ''; // Guest için boş string
    final localStats = ref.read(localStatisticsServiceProvider);
    
    // Convert seconds to minutes (rounded)
    final int totalSeconds = ref.read(currentExamProvider)?.durationInMinutes == null
        ? 0
        : (ref.read(currentExamProvider)!.durationInMinutes * 60);
    final int elapsed = totalSeconds > 0 ? (totalSeconds - _remainingSeconds) : 0;
    final int minutes = (elapsed / 60).round();
    if (minutes > 0) {
      localStats.addStudyTimeMinutes(userId: userId, minutes: minutes);
    }
    
    // Test tamamlama sayısını artır
    localStats.incrementTestCompleted(userId: userId);
    print('[ExamSimulationPage] Test completed - UserId: $userId');
    
    // Show final ad before showing results
    await ref.read(adDisplayProvider.notifier).forceShowAd();
    
    setState(() {
      _showResults = true;
    });
  }



  void _showEndExamConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sınavı Bitir'),
        content: const Text('Sınavı bitirmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeExam();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Bitir'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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

  void _exitExam() {
    final BuildContext currentContext = context;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sınavdan Çık'),
        content: const Text('Sınavdan çıkmak istediğinizden emin misiniz? Cevapladığınız sorular kaydedilmiştir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(currentExamProvider.notifier).clearExam();
              currentContext.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }

  void _showSolution() {
    final Exam? exam = ref.read(currentExamProvider);
    if (exam == null) return;
    
    final currentQuestion = exam.questions[exam.currentQuestionIndex];
    
    showDialog(
      context: context,
      builder: (BuildContext context) => SolutionPopup(
        solutionText: currentQuestion.explanation,
        questionText: currentQuestion.questionText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Exam? exam = ref.watch(currentExamProvider);
    final double fontSize = ref.watch(fontSizeProvider);
    
    // URL decode parameters for display with error handling
    String? decodedCategory;
    String? decodedProfession;
    String? decodedSubject;
    
    if (widget.category != null) {
      try {
        decodedCategory = Uri.decodeComponent(widget.category!);
      } catch (e) {
        try {
          String fixedCategory = widget.category!
              .replaceAll('%C4%B1', 'ı')
              .replaceAll('%C3%BC', 'ü')
              .replaceAll('%C3%B6', 'ö')
              .replaceAll('%C3%A7', 'ç')
              .replaceAll('%C4%9F', 'ğ')
              .replaceAll('%C5%9F', 'ş')
              .replaceAll('%C3%96', 'Ö')
              .replaceAll('%C3%9C', 'Ü')
              .replaceAll('%C3%87', 'Ç')
              .replaceAll('%C4%B0', 'İ')
              .replaceAll('%C4%9E', 'Ğ')
              .replaceAll('%C5%9E', 'Ş');
          decodedCategory = Uri.decodeComponent(fixedCategory);
        } catch (e2) {
          decodedCategory = widget.category!;
          print('Exam Display - Category URI decode error: $e');
        }
      }
    }
    
    if (widget.profession != null) {
      try {
        decodedProfession = Uri.decodeComponent(widget.profession!);
      } catch (e) {
        try {
          String fixedProfession = widget.profession!
              .replaceAll('%C4%B1', 'ı')
              .replaceAll('%C3%BC', 'ü')
              .replaceAll('%C3%B6', 'ö')
              .replaceAll('%C3%A7', 'ç')
              .replaceAll('%C4%9F', 'ğ')
              .replaceAll('%C5%9F', 'ş')
              .replaceAll('%C3%96', 'Ö')
              .replaceAll('%C3%9C', 'Ü')
              .replaceAll('%C3%87', 'Ç')
              .replaceAll('%C4%B0', 'İ')
              .replaceAll('%C4%9E', 'Ğ')
              .replaceAll('%C5%9E', 'Ş');
          decodedProfession = Uri.decodeComponent(fixedProfession);
        } catch (e2) {
          decodedProfession = widget.profession!;
          print('Exam Display - Profession URI decode error: $e');
        }
      }
    }
    
    if (widget.subject != null) {
      try {
        decodedSubject = Uri.decodeComponent(widget.subject!);
      } catch (e) {
        try {
          String fixedSubject = widget.subject!
              .replaceAll('%C4%B1', 'ı')
              .replaceAll('%C3%BC', 'ü')
              .replaceAll('%C3%B6', 'ö')
              .replaceAll('%C3%A7', 'ç')
              .replaceAll('%C4%9F', 'ğ')
              .replaceAll('%C5%9F', 'ş')
              .replaceAll('%C3%96', 'Ö')
              .replaceAll('%C3%9C', 'Ü')
              .replaceAll('%C3%87', 'Ç')
              .replaceAll('%C4%B0', 'İ')
              .replaceAll('%C4%9E', 'Ğ')
              .replaceAll('%C5%9E', 'Ş');
          decodedSubject = Uri.decodeComponent(fixedSubject);
        } catch (e2) {
          decodedSubject = widget.subject!;
          print('Exam Display - Subject URI decode error: $e');
        }
      }
    }

    if (exam == null) {
      return Scaffold(
        appBar: const StandardAppBar(
          title: 'Sınav Simülasyonu',
          subtitle: 'Yükleniyor...',
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showResults) {
      final ExamResult result = ExamResult(
        examId: exam.id,
        userId: 'current_user',
        completedAt: DateTime.now(),
        totalQuestions: exam.totalQuestions,
        correctAnswers: exam.correctAnswers,
        incorrectAnswers: exam.incorrectAnswers,
        blankAnswers: exam.blankAnswers,
        scorePercentage: exam.scorePercentage,
        timeTaken: Duration(seconds: (exam.durationInMinutes * 60) - _remainingSeconds),
        categoryPerformance: const {},
        incorrectQuestionIds: const [],
      );
      
      return ExamResultsModal(
        result: result,
        onReviewAnswers: () {
          setState(() {
            _showResults = false;
          });
        },
        onRetakeExam: () {
          _initializeExam();
          setState(() {
            _showResults = false;
          });
        },
        onBackToHome: () {
          ref.read(currentExamProvider.notifier).clearExam();
          context.go('/home');
        },
      );
    }

    final Question currentQuestion = exam.questions[exam.currentQuestionIndex];
    final int? userAnswer = exam.userAnswers[currentQuestion.id];

    return Scaffold(
      appBar: StandardAppBar(
        title: decodedSubject != null ? decodedSubject : (widget.examType?.displayName ?? 'Sınav'),
        subtitle: decodedCategory != null && decodedProfession != null 
            ? 'Ana Sayfa > Bakanlıklar > $decodedCategory > $decodedProfession > $decodedSubject > Test'
            : 'Test Ekranı',
        onBackPressed: _exitExam,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showFontSizeDialog(context),
            tooltip: 'Yazı Boyutu',
          ),
          ExamTimerWidget(
            remainingSeconds: _remainingSeconds,
            totalSeconds: exam.durationInMinutes * 60,
          ),
        ],
      ),
      body: Column(
        children: [
          ExamProgressBar(
            currentQuestion: exam.currentQuestionIndex + 1,
            totalQuestions: exam.questions.length,
            answeredQuestions: exam.userAnswers.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExamQuestionCard(
                question: currentQuestion,
                selectedAnswerIndex: _selectedAnswerIndex ?? userAnswer,
                onAnswerSelected: _selectAnswer,
                isReviewMode: exam.status == ExamStatus.completed,
                showCorrectAnswer: exam.status == ExamStatus.completed,
                showAnswerFeedback: _showAnswerFeedback,
                fontSize: fontSize,
                onShowSolution: _showSolution,
                isStarredOverride: _starredIds.contains(currentQuestion.id),
                onStarToggle: () {
                  // Optimistic toggle in questions state if available
                  ref.read(questionsProvider.notifier).toggleQuestionStar(currentQuestion.id);

                  // Persist via FavoritesService
                  final firebaseUser = ref.read(currentFirebaseUserProvider);
                  final userId = firebaseUser?.uid ?? '';
                  final favoritesService = ref.read(favoritesServiceProvider);
                  final newIsStarred = !_starredIds.contains(currentQuestion.id);
                  favoritesService.setStarStatus(
                    userId: userId,
                    questionId: currentQuestion.id,
                    isStarred: newIsStarred,
                  );
                  setState(() {
                    if (newIsStarred) {
                      _starredIds.add(currentQuestion.id);
                    } else {
                      _starredIds.remove(currentQuestion.id);
                    }
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (exam.currentQuestionIndex < exam.questions.length - 1) {
                        _nextQuestion();
                      } else {
                        _completeExam();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      exam.currentQuestionIndex < exam.questions.length - 1
                          ? 'Sonraki'
                          : 'Bitir',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _showEndExamConfirmation,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Bitir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}