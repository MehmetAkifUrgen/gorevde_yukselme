import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/questions_providers.dart';
import '../../../../core/providers/ad_providers.dart';
import 'random_questions_practice_page.dart';

class MiniQuestionsPage extends ConsumerStatefulWidget {
  final String selectedCategory;
  final String selectedMinistry;
  final String selectedProfession;

  const MiniQuestionsPage({
    super.key,
    required this.selectedCategory,
    required this.selectedMinistry,
    required this.selectedProfession,
  });

  @override
  ConsumerState<MiniQuestionsPage> createState() => _MiniQuestionsPageState();
}

class _MiniQuestionsPageState extends ConsumerState<MiniQuestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Sorular'),
        backgroundColor: AppTheme.primaryNavyBlue,
        foregroundColor: AppTheme.secondaryWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryNavyBlue, AppTheme.primaryNavyBlue.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavyBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mini Sorular',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.selectedCategory} - ${widget.selectedMinistry} - ${widget.selectedProfession}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subjects Section
            Consumer(
              builder: (context, ref, child) {
                final subjectsAsync = ref.watch(miniSubjectsProvider((
                  category: widget.selectedCategory,
                  ministry: widget.selectedMinistry,
                  profession: widget.selectedProfession,
                )));
                
                return subjectsAsync.when(
                  data: (subjects) {
                    if (subjects.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.lightGrey),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: AppTheme.darkGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bu seçim için henüz konu bulunmuyor.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.darkGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lütfen farklı bir seçim yapmayı deneyin.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.darkGrey.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.lightGrey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konular',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryNavyBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subjects.length,
                            itemBuilder: (context, index) {
                              final subject = subjects[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () => _startMiniQuestions(context, subject),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentGold.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.quiz_outlined,
                                              color: AppTheme.accentGold,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  subject,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Mini soruları başlat',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: AppTheme.darkGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppTheme.darkGrey,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Konular yüklenirken hata oluştu',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.errorRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.errorRed.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startMiniQuestions(BuildContext context, String subject) {
    // Mini soruları yükle
    ref.read(miniQuestionsStateProvider.notifier).loadMiniQuestions(
      category: widget.selectedCategory,
      ministry: widget.selectedMinistry,
      profession: widget.selectedProfession,
      subject: subject,
    );

    // Sorular sayfasına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiniQuestionsPracticePage(
          category: widget.selectedCategory,
          ministry: widget.selectedMinistry,
          profession: widget.selectedProfession,
          subject: subject,
        ),
      ),
    );
  }
}

class MiniQuestionsPracticePage extends ConsumerStatefulWidget {
  final String category;
  final String ministry;
  final String profession;
  final String subject;

  const MiniQuestionsPracticePage({
    super.key,
    required this.category,
    required this.ministry,
    required this.profession,
    required this.subject,
  });

  @override
  ConsumerState<MiniQuestionsPracticePage> createState() => _MiniQuestionsPracticePageState();
}

class _MiniQuestionsPracticePageState extends ConsumerState<MiniQuestionsPracticePage> {
  @override
  void initState() {
    super.initState();
    // Mini sorular counter'ını sıfırla
    ref.read(miniQuestionsCounterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final questionsState = ref.watch(miniQuestionsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryNavyBlue,
        foregroundColor: AppTheme.secondaryWhite,
        elevation: 0,
      ),
      body: questionsState.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: AppTheme.darkGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu konu için henüz soru bulunmuyor.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lütfen daha sonra tekrar deneyin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGrey.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RandomQuestionsPracticePage(
            questions: questions,
            questionCount: questions.length,
            title: widget.subject,
            isMiniQuestions: true, // Mini sorular için flag
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Sorular yüklenirken hata oluştu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.errorRed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorRed.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(miniQuestionsStateProvider.notifier).loadMiniQuestions(
                    category: widget.category,
                    ministry: widget.ministry,
                    profession: widget.profession,
                    subject: widget.subject,
                  );
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
