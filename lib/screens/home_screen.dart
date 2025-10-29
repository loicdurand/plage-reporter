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
            child: StreamBuilder<List<String>>(
              stream: firestore.getBeachNames(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final beaches = snapshot.data!;
                return ListView.builder(
                  itemCount: beaches.length,
                  itemBuilder: (context, index) => BeachCard(
                    beachName: beaches[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportScreen(beachName: beaches[index]),
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