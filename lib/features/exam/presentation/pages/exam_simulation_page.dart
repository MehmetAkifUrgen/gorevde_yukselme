import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/exam_model.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../widgets/exam_timer_widget.dart';
import '../widgets/exam_progress_bar.dart';
import '../widgets/exam_question_card.dart';
import '../widgets/exam_results_modal.dart';
import 'package:gorevde_yukselme/features/questions/presentation/widgets/font_size_slider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeExam();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          decodedRouteExamType = widget.routeExamType ?? '';
          print('Exam - routeExamType URI decode error: $e');
        }
        
        try {
          decodedCategory = Uri.decodeComponent(widget.category!);
        } catch (e) {
          decodedCategory = widget.category!;
          print('Exam - Category URI decode error: $e');
        }
        
        try {
          decodedProfession = Uri.decodeComponent(widget.profession!);
        } catch (e) {
          decodedProfession = widget.profession!;
          print('Exam - Profession URI decode error: $e');
        }
        
        try {
          decodedSubject = Uri.decodeComponent(widget.subject!);
        } catch (e) {
          decodedSubject = widget.subject!;
          print('Exam - Subject URI decode error: $e');
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
        // Data hierarchy: Category (exam type) > Ministry > Profession
        // Our conversion maps Profession into the "subject" dimension.
        // Therefore:
        // - filterByCategory should use routeExamType (top-level category)
        // - filterByProfession should use ministry
        // - filterBySubject should use profession
        final List<Question> filtered = await ref
            .read(
              questionsByCategoryProfessionAndSubjectProvider((
                category: decodedRouteExamType,
                profession: decodedProfession,
                subject: decodedSubject,
              )).future,
            );
        if (filtered.isEmpty) {
          _showErrorDialog('Sorular yüklenemedi. Lütfen tekrar deneyin.');
          return;
        }
        final int takeCount = math.min(filtered.length, mode.defaultQuestionCount);
        final List<Question> shuffled = List<Question>.from(filtered)..shuffle();
        questions = shuffled.take(takeCount).toList();
      } else {
        final List<Question> randomQuestions = ref.read(randomQuestionsProvider(mode.defaultQuestionCount));
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
        targetProfession: UserProfession.values.first, // TODO: Get from user profile
        questions: questions,
        durationInMinutes: mode.defaultDuration,
        status: ExamStatus.notStarted,
      );

      ref.read(currentExamProvider.notifier).startExam(exam);
      _remainingSeconds = mode.defaultDuration * 60;
      _startTimer();
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
  }

  void _submitAnswer() {
    final Exam? exam = ref.read(currentExamProvider);
    if (exam == null || _selectedAnswerIndex == null) return;

    final Question currentQuestion = exam.questions[exam.currentQuestionIndex];
    ref.read(currentExamProvider.notifier).answerQuestion(
      currentQuestion.id,
      _selectedAnswerIndex!,
    );

    setState(() {
      _selectedAnswerIndex = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    final Exam? exam = ref.read(currentExamProvider);
    if (exam == null) return;

    if (exam.currentQuestionIndex < exam.questions.length - 1) {
      ref.read(currentExamProvider.notifier).nextQuestion();
      setState(() {
        _selectedAnswerIndex = null;
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
      });
    }
  }

  void _completeExam() {
    _timer?.cancel();
    ref.read(currentExamProvider.notifier).completeExam();
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
        content: const Text('Sınavdan çıkmak istediğinizden emin misiniz? İlerlemeniz kaydedilmeyecek.'),
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
        decodedCategory = widget.category!;
        print('Exam Display - Category URI decode error: $e');
      }
    }
    
    if (widget.profession != null) {
      try {
        decodedProfession = Uri.decodeComponent(widget.profession!);
      } catch (e) {
        decodedProfession = widget.profession!;
        print('Exam Display - Profession URI decode error: $e');
      }
    }
    
    if (widget.subject != null) {
      try {
        decodedSubject = Uri.decodeComponent(widget.subject!);
      } catch (e) {
        decodedSubject = widget.subject!;
        print('Exam Display - Subject URI decode error: $e');
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
          context.pop();
        },
      );
    }

    final Question currentQuestion = exam.questions[exam.currentQuestionIndex];
    final bool isAnswered = exam.userAnswers.containsKey(currentQuestion.id);
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
                fontSize: fontSize,
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
                  child: OutlinedButton(
                    onPressed: exam.currentQuestionIndex > 0 ? _previousQuestion : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.primaryNavyBlue),
                    ),
                    child: const Text('Önceki'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isAnswered && _selectedAnswerIndex != null) {
                        _submitAnswer();
                      } else if (exam.currentQuestionIndex < exam.questions.length - 1) {
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
                      !isAnswered && _selectedAnswerIndex != null
                          ? 'Cevapla'
                          : exam.currentQuestionIndex < exam.questions.length - 1
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