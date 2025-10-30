import 'package:flutter/material.dart';
import '../widgets/beach_card.dart';
import '../services/firestore_service.dart';
import 'report_screen.dart';
import 'settings_screen.dart'; // ← Ajoute

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Sable & Sargasses')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Sable & Sargasses',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<Map<String, int>>(
        stream: firestore.getBeachPopularity(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final popularity = snapshot.data!;
          final sortedBeaches = popularity.keys.toList()
            ..sort((a, b) => popularity[b]!.compareTo(popularity[a]!));
          return ListView.builder(
            itemCount: sortedBeaches.length,
            itemBuilder: (context, index) => BeachCard(
              beachName: sortedBeaches[index],
              beachId: sortedBeaches[index].toLowerCase().replaceAll(' ', '-'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportScreen(beachName: sortedBeaches[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}