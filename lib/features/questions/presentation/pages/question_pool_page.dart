import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/questions_providers.dart' as questions_providers;
import '../../../../core/models/question_model.dart';
import 'random_questions_practice_page.dart';
import 'mini_questions_page.dart';

class QuestionPoolPage extends ConsumerStatefulWidget {
  const QuestionPoolPage({super.key});

  @override
  ConsumerState<QuestionPoolPage> createState() => _QuestionPoolPageState();
}

class _QuestionPoolPageState extends ConsumerState<QuestionPoolPage> {
  @override
  Widget build(BuildContext context) {
    final questionsState = ref.watch(questions_providers.questionsStateProvider);
    final selectedExam = ref.watch(selectedExamProvider);
    final selectedMinistry = ref.watch(selectedMinistryProvider);
    final selectedProfession = ref.watch(selectedProfessionProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Soru Havuzu'),
        backgroundColor: AppTheme.primaryNavyBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Dropdown Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sınav Türü, Bakanlık ve Meslek Seçimi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavyBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Exam Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedExam,
                    decoration: InputDecoration(
                      labelText: 'Gireceği Sınav',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.school),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    isExpanded: true,
                    items: _getAvailableExams(questionsState).toSet().map((exam) {
                      return DropdownMenuItem(
                        value: exam,
                        child: Text(exam),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(selectedExamProvider.notifier).setExam(value);
                        // Reset ministry and profession when exam changes
                        ref.read(selectedMinistryProvider.notifier).clearMinistry();
                        ref.read(selectedProfessionProvider.notifier).clearProfession();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ministry Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedMinistry != null && _getAvailableMinistries(questionsState, selectedExam).contains(selectedMinistry) 
                        ? selectedMinistry 
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Bakanlık',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.account_balance),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    isExpanded: true,
                    items: _getAvailableMinistries(questionsState, selectedExam).toSet().map((ministry) {
                      return DropdownMenuItem(
                        value: ministry,
                        child: Text(ministry),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(selectedMinistryProvider.notifier).setMinistry(value);
                        // Reset profession when ministry changes
                        ref.read(selectedProfessionProvider.notifier).clearProfession();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Profession Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedProfession != null && _getAvailableProfessions(questionsState, selectedExam, selectedMinistry).contains(selectedProfession) 
                        ? selectedProfession 
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Meslek',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.work),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    isExpanded: true,
                    items: _getAvailableProfessions(questionsState, selectedExam, selectedMinistry).toSet().map((profession) {
                      return DropdownMenuItem(
                        value: profession,
                        child: Text(profession),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(selectedProfessionProvider.notifier).setProfession(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  // Soruları Karıştır Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () => _startShuffledQuestions(context),
                      icon: const Icon(Icons.shuffle, size: 28),
                      label: const Text(
                        'Soruları Karıştır',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavyBlue,
                        foregroundColor: AppTheme.secondaryWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mini Quiz Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () => _startMiniQuiz(context),
                      icon: const Icon(Icons.quiz, size: 28),
                      label: const Text(
                        'AI Destekli Eşsiz Sorular',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: AppTheme.secondaryWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),)
    );
  }

  List<String> _getAvailableExams(AsyncValue<List<Question>> questionsState) {
    return questionsState.when(
      data: (questions) {
        final examTypes = questions
            .map((q) => q.id.split('_').isNotEmpty ? q.id.split('_')[0] : '')
            .where((exam) => exam.isNotEmpty)
            .toSet()
            .toList();
        return examTypes;
      },
      loading: () => [], // Boş liste
      error: (_, __) => [], // Boş liste
    );
  }

  List<String> _getAvailableMinistries(
    AsyncValue<List<Question>> questionsState,
    String? selectedExam,
  ) {
    return questionsState.when(
      data: (questions) {
        List<Question> filteredQuestions = questions;
        
        // Eğer sınav türü seçiliyse, önce ona göre filtrele
        if (selectedExam != null) {
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.isNotEmpty) {
              return parts[0] == selectedExam;
            }
            return false;
          }).toList();
        }
        
        // Bakanlık = 2. kısım (parts[1])
        final ministries = filteredQuestions
            .map((q) => q.id.split('_').length >= 2 ? q.id.split('_')[1] : '')
            .where((ministry) => ministry.isNotEmpty)
            .toSet()
            .toList();
        return ministries;
      },
      loading: () => [], // Boş liste
      error: (_, __) => [], // Boş liste
    );
  }

  void _startMiniQuiz(BuildContext context) {
    final selectedExam = ref.read(selectedExamProvider);
    final selectedMinistry = ref.read(selectedMinistryProvider);
    final selectedProfession = ref.read(selectedProfessionProvider);
    
    // Tüm seçimlerin yapıldığını kontrol et
    if (selectedExam == null || selectedMinistry == null || selectedProfession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce sınav türü, bakanlık ve meslek seçimlerini yapın.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Mini sorular sayfasına seçimleri aktararak yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiniQuestionsPage(
          selectedCategory: selectedExam,
          selectedMinistry: selectedMinistry,
          selectedProfession: selectedProfession,
        ),
      ),
    );
  }

  List<String> _getAvailableProfessions(
    AsyncValue<List<Question>> questionsState,
    String? selectedExam,
    String? selectedMinistry,
  ) {
    return questionsState.when(
      data: (questions) {
        List<Question> filteredQuestions = questions;
        
        // Eğer sınav türü seçiliyse, önce ona göre filtrele
        if (selectedExam != null) {
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.isNotEmpty) {
              return parts[0] == selectedExam;
            }
            return false;
          }).toList();
        }
        
        // Eğer bakanlık seçiliyse, ona göre de filtrele
        if (selectedMinistry != null) {
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.length >= 2) {
              return parts[1] == selectedMinistry;
            }
            return false;
          }).toList();
        }
        
        // Meslek = 3. kısım (parts[2])
        final professions = filteredQuestions
            .map((q) => q.id.split('_').length >= 3 ? q.id.split('_')[2] : '')
            .where((profession) => profession.isNotEmpty)
            .toSet()
            .toList();
        return professions;
      },
      loading: () => [], // Boş liste
      error: (_, __) => [], // Boş liste
    );
  }

  void _startShuffledQuestions(BuildContext context) {
    final questionsState = ref.read(questions_providers.questionsStateProvider);
    final selectedExam = ref.read(selectedExamProvider);
    final selectedMinistry = ref.read(selectedMinistryProvider);
    final selectedProfession = ref.read(selectedProfessionProvider);
    
    // En az bir filtre seçili olmalı
    if (selectedExam == null && selectedMinistry == null && selectedProfession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
               content: Text('Lütfen en az bir filtre seçin (Sınav Türü, Bakanlık veya Meslek)'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    questionsState.when(
      data: (questions) {
        print('[QuestionPoolPage] Total questions loaded: ${questions.length}');
        
        // Seçili filtrelerle soruları filtrele
        List<Question> filteredQuestions = questions;
        
        if (selectedExam != null) {
          print('[QuestionPoolPage] Filtering by exam: $selectedExam');
          print('[QuestionPoolPage] Sample question IDs: ${questions.take(3).map((q) => q.id).toList()}');
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.isNotEmpty) {
              final matches = parts[0] == selectedExam;
              if (!matches) {
                print('[QuestionPoolPage] Question ${question.id} does not match exam filter');
              }
              return matches;
            }
            return false;
          }).toList();
          print('[QuestionPoolPage] After exam filter: ${filteredQuestions.length} questions');
        }
        
        if (selectedMinistry != null) {
          print('[QuestionPoolPage] Filtering by ministry: $selectedMinistry');
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.length >= 2) {
              return parts[1] == selectedMinistry;
            }
            return false;
          }).toList();
          print('[QuestionPoolPage] After ministry filter: ${filteredQuestions.length} questions');
        }
        
        if (selectedProfession != null) {
          print('[QuestionPoolPage] Filtering by profession: $selectedProfession');
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.length >= 3) {
              return parts[2] == selectedProfession;
            }
            return false;
          }).toList();
          print('[QuestionPoolPage] After profession filter: ${filteredQuestions.length} questions');
        }
        
        // Mini Quiz sorularını hariç tut
        filteredQuestions = filteredQuestions.where((question) {
          return !question.id.contains('Mini Quiz');
        }).toList();
        
        if (filteredQuestions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seçili kriterlere uygun soru bulunamadı.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        
        // Soruları karıştır
        filteredQuestions.shuffle();
        
        // Karıştırılmış sorular sayfasına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RandomQuestionsPracticePage(
              questions: filteredQuestions,
              questionCount: filteredQuestions.length, // Tüm soruları göster
            ),
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sorular yükleniyor, lütfen bekleyin...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      error: (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}