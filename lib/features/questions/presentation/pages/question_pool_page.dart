import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/questions_providers.dart' as questions_providers;
import '../../../../core/models/question_model.dart';
import 'random_questions_practice_page.dart';

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
                    'Sınav, Bakanlık ve Meslek Seçimi',
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
            Expanded(
              child: Column(
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
                        'Mini Quiz',
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
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableExams(AsyncValue<List<Question>> questionsState) {
    // Return static exams based on JSON structure
    return ['Görevde Yükselme', 'Ünvan Değişikliği'];
  }

  List<String> _getAvailableMinistries(
    AsyncValue<List<Question>> questionsState,
    String? selectedExam,
  ) {
    // Return static ministries based on JSON structure
    return ['Adalet Bakanlığı'];
  }

  void _startMiniQuiz(BuildContext context) {
    final questionsState = ref.read(questions_providers.questionsStateProvider);
    
    questionsState.when(
      data: (questions) {
        // Mini Quiz sorularını filtrele
        final miniQuizQuestions = questions.where((question) {
          return question.id.contains('Mini Quiz') || 
                 question.id.contains('Genel Kültür') ||
                 question.id.contains('Hızlı Test');
        }).toList();
        
        if (miniQuizQuestions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mini Quiz soruları henüz eklenmemiş. Lütfen daha sonra tekrar deneyin.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        
        // Mini Quiz sayfasına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RandomQuestionsPracticePage(
              questions: miniQuizQuestions,
              questionCount: 10, // Mini quiz için 10 soru
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

  List<String> _getAvailableProfessions(
    AsyncValue<List<Question>> questionsState,
    String? selectedExam,
    String? selectedMinistry,
  ) {
    // Return professions based on selected exam
    if (selectedExam == 'Görevde Yükselme') {
      return ['İdare Memuru', 'İdari İşler Müdürü', 'İkinci Müdür', 'İnfaz Koruma Baş Memurluğu', 'Şef', 'Yazı İşleri Müdürü', 'Zabıt Katibi', 'İcra Müdür ve Müdür Yardımcıları'];
    } else if (selectedExam == 'Ünvan Değişikliği') {
      return ['İdare Memuru', 'Şef', 'Sayman', 'İkinci Müdür', 'İnfaz Koruma Baş Memurluğu', 'Sosyolog', 'Öğretmen', 'Gıda Mühendisi', 'Makine Mühendisi', 'Orman Endüstri Mühendisi', 'Çevre Mühendisi', 'Elektrik Elektronik Mühendisi', 'Tekstil Mühendisi', 'Bilgisayar Teknisyeni', 'Mobilya Teknisyeni', 'İnşaat Teknisyeni', 'Gıda Teknisyeni', 'Elektrik Teknisyeni', 'Ziraat Teknisyeni', 'Makine Teknisyeni', 'Sağlık Memuru'];
    }
    return ['İdare Memuru', 'Şef', 'İkinci Müdür'];
  }

  void _startShuffledQuestions(BuildContext context) {
    final questionsState = ref.read(questions_providers.questionsStateProvider);
    final selectedExam = ref.read(selectedExamProvider);
    final selectedMinistry = ref.read(selectedMinistryProvider);
    final selectedProfession = ref.read(selectedProfessionProvider);
    
    questionsState.when(
      data: (questions) {
        // Seçili filtrelerle soruları filtrele
        List<Question> filteredQuestions = questions;
        
        if (selectedExam != null) {
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.isNotEmpty) {
              return parts[0] == selectedExam;
            }
            return false;
          }).toList();
        }
        
        if (selectedMinistry != null) {
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.length >= 2) {
              return parts[1] == selectedMinistry;
            }
            return false;
          }).toList();
        }
        
        if (selectedProfession != null) {
          filteredQuestions = filteredQuestions.where((question) {
            final parts = question.id.split('_');
            if (parts.length >= 3) {
              return parts[2] == selectedProfession;
            }
            return false;
          }).toList();
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