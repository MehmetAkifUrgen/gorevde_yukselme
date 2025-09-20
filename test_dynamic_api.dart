import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gorevde_yukselme/core/providers/questions_providers.dart';

class DynamicApiTestWidget extends ConsumerStatefulWidget {
  const DynamicApiTestWidget({super.key});

  @override
  ConsumerState<DynamicApiTestWidget> createState() => _DynamicApiTestWidgetState();
}

class _DynamicApiTestWidgetState extends ConsumerState<DynamicApiTestWidget> {
  String? selectedCategory;
  String? selectedProfession;

  @override
  Widget build(BuildContext context) {
    final cacheStatus = ref.watch(cacheStatusProvider);
    final categories = ref.watch(availableCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic API Test'),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    cacheStatus.when(
                      data: (isCached) => Text(
                        isCached ? 'Data is cached' : 'No cached data',
                        style: TextStyle(
                          color: isCached ? Colors.green : Colors.orange,
                        ),
                      ),
                      loading: () => const Text('Checking cache...'),
                      error: (error, _) => Text('Error: $error'),
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
                      'Categories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    categories.when(
                      data: (categoryList) => DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text('Select Category'),
                        isExpanded: true,
                        items: categoryList.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            selectedProfession = null; // Reset profession when category changes
                          });
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error loading categories: $error'),
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
                        'Professions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final professions = ref.watch(availableProfessionsProvider(selectedCategory!));
                          return professions.when(
                            data: (professionList) => DropdownButton<String>(
                              value: selectedProfession,
                              hint: const Text('Select Profession'),
                              isExpanded: true,
                              items: professionList.map((profession) {
                                return DropdownMenuItem<String>(
                                  value: profession,
                                  child: Text(profession),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedProfession = value;
                                });
                              },
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (error, _) => Text('Error loading professions: $error'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Subjects List
            if (selectedCategory != null && selectedProfession != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Subjects',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final subjects = ref.watch(availableSubjectsProvider((
                            category: selectedCategory!,
                            profession: selectedProfession!,
                          )));
                          return subjects.when(
                            data: (subjectList) => Column(
                              children: subjectList.map((subject) {
                                return ListTile(
                                  leading: const Icon(Icons.book),
                                  title: Text(subject),
                                  dense: true,
                                );
                              }).toList(),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (error, _) => Text('Error loading subjects: $error'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}