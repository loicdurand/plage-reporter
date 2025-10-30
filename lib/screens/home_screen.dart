// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/beach_card.dart';
import '../services/firestore_service.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestore = FirestoreService();

  // === FILTRES ===
  bool filterNoSargasses = false;
  bool filterLowWaves = false;
  bool filterLowCrowd = false;
  bool filterLowNoise = false;

  // === BOUTON FILTRE ===
  Widget _buildFilterButton(String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // === BARRE DE FILTRES ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('Sans sargasses', filterNoSargasses, () {
                    setState(() => filterNoSargasses = !filterNoSargasses);
                  }),
                  _buildFilterButton('Peu de vagues', filterLowWaves, () {
                    setState(() => filterLowWaves = !filterLowWaves);
                  }),
                  _buildFilterButton('Peu de monde', filterLowCrowd, () {
                    setState(() => filterLowCrowd = !filterLowCrowd);
                  }),
                  _buildFilterButton('Calme', filterLowNoise, () {
                    setState(() => filterLowNoise = !filterLowNoise);
                  }),
                ],
              ),
            ),
          ),

          // === LISTE DES PLAGES ===
          Expanded(
            child: StreamBuilder<Map<String, int>>(
              stream: firestore.getBeachPopularity(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final popularity = snapshot.data ?? {};
                final sortedBeaches = popularity.keys.toList()
                  ..sort((a, b) => (popularity[b] ?? 0).compareTo(popularity[a] ?? 0));

                if (sortedBeaches.isEmpty) {
                  return const Center(child: Text('Aucune plage enregistrée.'));
                }

                return ListView.builder(
                  itemCount: sortedBeaches.length,
                  itemBuilder: (context, index) {
                    final beachName = sortedBeaches[index];
                    final beachId = beachName.toLowerCase().replaceAll(' ', '-');

                    return BeachCard(
                      beachName: beachName,
                      beachId: beachId,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReportScreen(beachName: beachName)),
                      ),
                      // === ON PASSE LES FILTRES ===
                      filterNoSargasses: filterNoSargasses,
                      filterLowWaves: filterLowWaves,
                      filterLowCrowd: filterLowCrowd,
                      filterLowNoise: filterLowNoise,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}