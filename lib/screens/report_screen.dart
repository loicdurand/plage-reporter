import 'package:flutter/material.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';
import 'comments_screen.dart';

class ReportScreen extends StatefulWidget {
  final String? beachName;
  const ReportScreen({super.key, this.beachName});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int sargassesLevel = 0;
  int wavesLevel = 0;
  int crowdLevel = 0;
  int noiseLevel = 0;
  int rating = 3;
  final commentController = TextEditingController();
  String? selectedBeach;

  final Map<int, String> levelLabels = {
    0: 'Aucun',
    1: 'Peu gênant',
    2: 'Gênant',
    3: 'Impraticable',
  };

  @override
  void initState() {
    super.initState();
    if (widget.beachName != null) {
      selectedBeach = widget.beachName;
    }
  }

  // Gros carré avec label + barres
  Widget _buildLevelSquare(
      String label, int currentLevel, Function(int) onChanged) {
    return GestureDetector(
      onTap: () => onChanged((currentLevel + 1) % 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor, // ← Fond dynamique
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color, // ← Texte dynamique
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 24,
                  height: 10 + index * 6.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index < currentLevel
                        ? Colors.orange.shade600
                        : Theme.of(context)
                            .colorScheme
                            .surfaceVariant, // ← Gris adapté
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            if (currentLevel > 0) ...[
              const SizedBox(height: 8),
              Text(
                levelLabels[currentLevel]!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Pop-up si tout vide
  void _showEmptyReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avis incomplet'),
        content: const Text(
          'Pas de vague, pas de sargasses, c’est cool ! '
          'Pourriez-vous dans ce cas saisir au moins un commentaire ?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    return "il y a ${diff.inDays} j";
  }

  Widget _buildRecentComments(String beachId) {
    final firestore = FirestoreService();
    return StreamBuilder<List<BeachReport>>(
      stream: firestore.getReports(beachId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox.shrink();
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Aucun commentaire pour cette plage.');
        }

        final comments =
            snapshot.data!.where((r) => r.comment != null).take(3).toList();

        if (comments.isEmpty)
          return const Text('Aucun commentaire pour cette plage.');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Derniers commentaires laissés :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...comments.map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('"${r.comment}"',
                      style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700])),
                  subtitle: Text(_timeAgo(r.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommentsScreen(
                      beachId: beachId, beachName: selectedBeach!),
                ),
              ),
              child: const Text('Voir tous les commentaires'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Donner un avis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown plage
            StreamBuilder<List<String>>(
              stream:
                  firestore.getBeachPopularity().map((m) => m.keys.toList()),
              builder: (context, snapshot) {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Plage',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  value: selectedBeach,
                  items: snapshot.data
                      ?.map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedBeach = v),
                );
              },
            ),
            const SizedBox(height: 24),

            // Grille 2x2 gros carrés
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildLevelSquare('Sargasses', sargassesLevel,
                    (l) => setState(() => sargassesLevel = l)),
                _buildLevelSquare('Vagues', wavesLevel,
                    (l) => setState(() => wavesLevel = l)),
                _buildLevelSquare(
                    'Foule', crowdLevel, (l) => setState(() => crowdLevel = l)),
                _buildLevelSquare(
                    'Bruit', noiseLevel, (l) => setState(() => noiseLevel = l)),
              ],
            ),
            const SizedBox(height: 24),

            // Note avec étoiles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Note générale',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => rating = i + 1),
                      child: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Commentaire
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32), // Marge généreuse

            // Derniers commentaires
            if (selectedBeach != null)
              _buildRecentComments(
                  selectedBeach!.toLowerCase().replaceAll(' ', '-')),

            const SizedBox(height: 24),

            // Bouton envoyer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (selectedBeach == null) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Aucune plage'),
                        content: const Text('Veuillez choisir une plage.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'))
                        ],
                      ),
                    );
                  } else if (sargassesLevel == 0 &&
                      wavesLevel == 0 &&
                      crowdLevel == 0 &&
                      noiseLevel == 0 &&
                      commentController.text.isEmpty) {
                    _showEmptyReportDialog();
                  } else {
                    firestore.addReport(BeachReport(
                      beachId:
                          selectedBeach!.toLowerCase().replaceAll(' ', '-'),
                      beachName: selectedBeach!,
                      sargassesLevel: sargassesLevel,
                      wavesLevel: wavesLevel,
                      crowdLevel: crowdLevel,
                      noiseLevel: noiseLevel,
                      rating: rating,
                      comment: commentController.text.isEmpty
                          ? null
                          : commentController.text,
                      timestamp: DateTime.now(),
                    ));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Envoyer l’avis',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
