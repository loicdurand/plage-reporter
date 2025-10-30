// lib/widgets/beach_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';

class BeachCard extends StatefulWidget {
  final String beachName;
  final String beachId;
  final VoidCallback onTap;
  final bool filterNoSargasses;
  final bool filterLowWaves;
  final bool filterLowCrowd;
  final bool filterLowNoise;

  const BeachCard({
    super.key,
    required this.beachName,
    required this.beachId,
    required this.onTap,
    this.filterNoSargasses = false,
    this.filterLowWaves = false,
    this.filterLowCrowd = false,
    this.filterLowNoise = false,
  });

  @override
  State<BeachCard> createState() => _BeachCardState();
}

class _BeachCardState extends State<BeachCard> {
  List<BeachReport>? _cachedReports;
  final firestore = FirestoreService();

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    return "il y a ${diff.inDays} j";
  }

  Widget _getLevelIcon(int level, IconData icon) {
    final colors = [
      Colors.grey,
      Colors.orangeAccent,
      Colors.orange,
      Colors.red
    ];
    final labels = ['', 'Peu', 'Moyen', 'Élevé'];
    return Row(
      children: [
        Icon(icon, color: colors[level], size: 20),
        const SizedBox(width: 4),
        Text(labels[level],
            style: TextStyle(fontSize: 12, color: colors[level])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              widget.beachName[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(widget.beachName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: StreamBuilder<List<BeachReport>>(
            stream: firestore.getReports(widget.beachId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _cachedReports = snapshot.data!;
              }
              final reports = _cachedReports ?? [];
              if (reports.isEmpty) {
                return const Text("Aucun avis");
              }
              final report = reports.first;

              // === FILTRES ===
              if (widget.filterNoSargasses && report.sargassesLevel != 0) {
                return const SizedBox.shrink();
              }
              if (widget.filterLowWaves && report.wavesLevel > 1) {
                return const SizedBox.shrink();
              }
              if (widget.filterLowCrowd && report.crowdLevel > 1) {
                return const SizedBox.shrink();
              }
              if (widget.filterLowNoise && report.noiseLevel > 1) {
                return const SizedBox.shrink();
              }
              // === FIN FILTRES ===

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeAgo(report.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _getLevelIcon(report.sargassesLevel, Icons.eco),
                      const SizedBox(width: 8),
                      _getLevelIcon(report.wavesLevel, Icons.waves),
                      const SizedBox(width: 8),
                      _getLevelIcon(report.crowdLevel, Icons.people),
                      const SizedBox(width: 8),
                      _getLevelIcon(report.noiseLevel, Icons.volume_up),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < report.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              )),
                      const Spacer(),
                      Text("${reports.length} avis"),
                      const SizedBox(width: 8),
                      // === BOUTON WHATSAPP ===
                      GestureDetector(
                        onTap: () {
                          final levelText = (level) => [
                                'Aucun',
                                'Peu gênant',
                                'Gênant',
                                'Impraticable'
                              ][level];
                          final message = Uri.encodeComponent(
                              "Plage ${report.beachName} :\n"
                              "• Sargasses : ${levelText(report.sargassesLevel)}\n"
                              "• Vagues : ${levelText(report.wavesLevel)}\n"
                              "• Foule : ${levelText(report.crowdLevel)}\n"
                              "• Bruit : ${levelText(report.noiseLevel)}\n"
                              "• Note : ${report.rating} étoiles\n"
                              "${report.comment != null ? 'Quote: \"$report.comment\"' : ''}");
                          final url = 'https://wa.me/?text=$message';
                          launchUrl(Uri.parse(url));
                        },
                        child: const Icon(Icons.share,
                            size: 20, color: Colors.green),
                      ),
                    ],
                  ),
                  // === COMMENTAIRE ===
                  if (report.comment != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${report.comment}"',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              );
            },
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}