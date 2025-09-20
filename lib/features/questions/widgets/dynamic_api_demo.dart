import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/questions_providers.dart';

class DynamicApiDemo extends ConsumerWidget {
  const DynamicApiDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableCategories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedProfession = ref.watch(selectedProfessionProvider);
    final filteredQuestions = ref.watch(filteredQuestionsProvider);
    final cacheStatus = ref.watch(cacheStatusProvider);
    
    // Watch available professions only if a category is selected
    final availableProfessions = selectedCategory != null 
        ? ref.watch(availableProfessionsProvider(selectedCategory))
        : const AsyncValue<List<String>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic API Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cache Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cache Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    cacheStatus.when(
                      data: (status) => Text(
                        status ? 'Cache is fresh' : 'Cache expired or empty',
                        style: TextStyle(
                          color: status ? Colors.green : Colors.orange,
                        ),
                      ),
                      loading: () => const Text('Checking cache...'),
                      error: (error, _) => Text(
                        'Cache error: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Categories Dropdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Categories (Dynamic)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    availableCategories.when(
                      data: (categories) => DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text('Select Category'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              )),
                        ],
                        onChanged: (value) {
                          ref.read(selectedCategoryProvider.notifier).state = value;
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text(
                        'Error loading categories: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Professions Dropdown
            if (selectedCategory != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Professions (Dynamic)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      availableProfessions.when(
                        data: (professions) => DropdownButton<String>(
                          value: selectedProfession,
                          hint: const Text('Select Profession'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Professions'),
                            ),
                            ...professions.map((profession) => DropdownMenuItem(
                                  value: profession,
                                  child: Text(profession),
                                )),
                          ],
                          onChanged: (value) {
                            ref.read(selectedProfessionProvider.notifier).state = value;
                          },
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, _) => Text(
                          'Error loading professions: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Questions List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questions (${filteredQuestions.when(
                          data: (questions) => questions.length.toString(),
                          loading: () => '...',
                          error: (_, __) => 'Error',
                        )})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filteredQuestions.when(
                          data: (questions) {
                            if (questions.isEmpty) {
                              return const Center(
                                child: Text('No questions found for the selected filters.'),
                              );
                            }
                            return ListView.builder(
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                final question = questions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ExpansionTile(
                                    title: Text(
                                      'Q${index + 1}: ${question.questionText}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      'ID: ${question.id}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Options:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            ...question.options.asMap().entries.map(
                                                  (entry) => Padding(
                                                    padding: const EdgeInsets.only(left: 16, top: 4),
                                                    child: Text(
                                                      '${String.fromCharCode(65 + entry.key)}) ${entry.value}',
                                                      style: TextStyle(
                                                        color: entry.key == question.correctAnswerIndex
                                                            ? Colors.green
                                                            : null,
                                                        fontWeight: entry.key == question.correctAnswerIndex
                                                            ? FontWeight.bold
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Explanation:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 16, top: 4),
                                              child: Text(question.explanation),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading questions: $error',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.invalidate(questionsStateProvider);
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
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh data
          ref.invalidate(questionsStateProvider);
          ref.read(selectedCategoryProvider.notifier).state = null;
          ref.read(selectedProfessionProvider.notifier).state = null;
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}