import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/beach_card.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sable & Sargasses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search beaches...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Implement search filter
              },
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: Text('No Sargasses'), onSelected: (_) {}),
              FilterChip(label: Text('Calm Sea'), onSelected: (_) {}),
              FilterChip(label: Text('Quiet'), onSelected: (_) {}),
            ],
          ),
          Expanded(
            child: StreamBuilder<Map<String, int>>(
              stream: firestore.getBeachPopularity(), // ← Nouvelle méthode
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final popularity = snapshot.data!;
                final sortedBeaches = popularity.keys.toList()
                  ..sort((a, b) => popularity[b]!.compareTo(popularity[a]!));
                return ListView.builder(
                  itemCount: sortedBeaches.length,
                  itemBuilder: (context, index) => BeachCard(
                    beachName: sortedBeaches[index],
                    beachId: sortedBeaches[index]
                        .toLowerCase()
                        .replaceAll(' ', '-'), // ← CALCULÉ UNE FOIS
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportScreen(beachName: sortedBeaches[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportScreen()),
            ),
            child: const Text('Add New Beach'),
          ),
        ],
      ),
    );
  }
}
