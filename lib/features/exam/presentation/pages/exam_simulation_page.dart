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
import '../widgets/exam_timer_widget.dart';
import '../widgets/exam_progress_bar.dart';
import '../widgets/exam_question_card.dart';
import '../widgets/exam_results_modal.dart';
import 'package:gorevde_yukselme/features/questions/presentation/widgets/font_size_slider.dart';

class ExamSimulationPage extends ConsumerStatefulWidget {
  final ExamType? examType;
  final String? professionFilter;

  const ExamSimulationPage({
    super.key,
    this.examType,
    this.professionFilter,
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

  void _initializeExam() {
    final examType = widget.examType ?? ExamType.miniExam;
    final questions = ref.read(randomQuestionsProvider(examType.defaultQuestionCount));
    
    if (questions.isEmpty) {
      _showErrorDialog('Sorular yüklenemedi. Lütfen tekrar deneyin.');
      return;
    }

    final exam = Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: examType.displayName,
      type: examType,
      targetProfession: UserProfession.values.first, // TODO: Get from user profile
      questions: questions,
      durationInMinutes: examType.defaultDuration,
      status: ExamStatus.notStarted,
    );

    ref.read(currentExamProvider.notifier).startExam(exam);
    _remainingSeconds = examType.defaultDuration * 60;
    _startTimer();
  }

  void _startTimer() {
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      builder: (context) => AlertDialog(
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
    final exam = ref.read(currentExamProvider);
    if (exam == null || _selectedAnswerIndex == null) return;

    final currentQuestion = exam.questions[exam.currentQuestionIndex];
    ref.read(currentExamProvider.notifier).answerQuestion(
      currentQuestion.id,
      _selectedAnswerIndex!,
    );

    setState(() {
      _selectedAnswerIndex = null;
    });

    // Auto-advance to next question after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    final exam = ref.read(currentExamProvider);
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
    final exam = ref.read(currentExamProvider);
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

  void _finishExam() {
    _completeExam();
  }

  void _showEndExamConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _exitExam() {
    final currentContext = context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
    final exam = ref.watch(currentExamProvider);
    final fontSize = ref.watch(fontSizeProvider);

    if (exam == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sınav Simülasyonu'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showResults) {
      // Create a mock ExamResult for now - this should be properly implemented
      final result = ExamResult(
        examId: exam.id,
        userId: 'current_user', // This should come from auth
        completedAt: DateTime.now(),
        totalQuestions: exam.totalQuestions,
        correctAnswers: exam.correctAnswers,
        incorrectAnswers: exam.incorrectAnswers,
        scorePercentage: exam.scorePercentage,
        timeTaken: Duration(seconds: (exam.durationInMinutes * 60) - _remainingSeconds),
        categoryPerformance: {},
        incorrectQuestionIds: [],
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

    final currentQuestion = exam.questions[exam.currentQuestionIndex];
    final isAnswered = exam.userAnswers.containsKey(currentQuestion.id);
    final userAnswer = exam.userAnswers[currentQuestion.id];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType?.name ?? 'Sınav'}'),
        backgroundColor: AppTheme.primaryNavyBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitExam,
        ),
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
          // Progress Bar
          ExamProgressBar(
            currentQuestion: exam.currentQuestionIndex + 1,
            totalQuestions: exam.questions.length,
            answeredQuestions: exam.userAnswers.length,
          ),
          
          // Question Content
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
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous Button
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
                
                // Submit/Next Button
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
                
                // End Exam Button
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