import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/questions_providers.dart';

/// Demo widget showing how to use the new API-based questions system
class ApiQuestionsDemo extends ConsumerWidget {
  const ApiQuestionsDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(questionsStateProvider);
    final availableCategories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedProfession = ref.watch(selectedProfessionProvider);
    final cacheStatus = ref.watch(cacheStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Questions Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(questionsStateProvider.notifier).refreshQuestions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              ref.read(questionsStateProvider.notifier).clearCache();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Cache Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: cacheStatus.when(
              data: (isCached) => Text(
                isCached ? 'Data is cached ✓' : 'No cached data',
                style: TextStyle(
                  color: isCached ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const Text('Checking cache...'),
              error: (_, __) => const Text('Cache check failed'),
            ),
          ),
          
          // Categories Dropdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: availableCategories.when(
              data: (categories) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(),
                ),
                value: selectedCategory,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...categories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  )),
                ],
                onChanged: (value) {
                  ref.read(selectedCategoryProvider.notifier).state = value;
                  ref.read(selectedProfessionProvider.notifier).state = null;
                  
                  if (value != null) {
                    ref.read(questionsStateProvider.notifier)
                        .loadQuestionsByCategory(value);
                  } else {
                    ref.read(questionsStateProvider.notifier).loadQuestions();
                  }
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Error loading categories: $error'),
            ),
          ),
          
          // Professions Dropdown (shown when category is selected)
          if (selectedCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer(
                builder: (context, ref, child) {
                  final professionsAsync = ref.watch(
                    availableProfessionsProvider(selectedCategory),
                  );
                  
                  return professionsAsync.when(
                    data: (professions) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Profession',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedProfession,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Professions'),
                        ),
                        ...professions.map((profession) => DropdownMenuItem<String>(
                          value: profession,
                          child: Text(profession),
                        )),
                      ],
                      onChanged: (value) {
                        ref.read(selectedProfessionProvider.notifier).state = value;
                        
                        if (value != null) {
                          ref.read(questionsStateProvider.notifier)
                              .loadQuestionsByCategoryAndProfession(
                                selectedCategory,
                                value,
                              );
                        } else {
                          ref.read(questionsStateProvider.notifier)
                              .loadQuestionsByCategory(selectedCategory);
                        }
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text('Error loading professions: $error'),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Questions List
          Expanded(
            child: questionsState.when(
              data: (questions) => questions.isEmpty
                  ? const Center(
                      child: Text(
                        'No questions available',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Question ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              question.questionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.questionText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...question.options.asMap().entries.map(
                                      (entry) {
                                        final optionIndex = entry.key;
                                        final option = entry.value;
                                        final isCorrect = optionIndex == question.correctAnswerIndex;
                                        
                                        return Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isCorrect 
                                                ? Colors.green.shade50 
                                                : Colors.grey.shade50,
                                            border: Border.all(
                                              color: isCorrect 
                                                  ? Colors.green 
                                                  : Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${String.fromCharCode(65 + optionIndex)}) ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isCorrect 
                                                      ? Colors.green.shade700 
                                                      : Colors.black87,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    color: isCorrect 
                                                        ? Colors.green.shade700 
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              if (isCorrect)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green.shade700,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    if (question.explanation.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          border: Border.all(color: Colors.blue.shade200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Explanation:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              question.explanation,
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading questions from API...'),
                  ],
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading questions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(questionsStateProvider.notifier).loadQuestions();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}