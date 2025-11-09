// lib/widgets/beach_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';

class BeachCard extends StatefulWidget {
  final String? imagePath;
  final String beachName;
  final String beachId;
  final VoidCallback onTap;
  final bool filterNoSargasses;
  final bool filterLowWaves;
  final bool filterLowCrowd;
  final bool filterLowNoise;

  const BeachCard({
    super.key,
    this.imagePath,
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
    final labels = [
      '',
      'Peu',
      'Moy',
      'Élevé'
    ]; // ← Labels raccourcis pour place
    return Row(
      mainAxisSize: MainAxisSize.min, // ← Min space
      children: [
        Icon(icon, color: colors[level], size: 18), // ← Size réduit
        const SizedBox(width: 2), // ← Espace réduit
        Text(labels[level],
            style:
                TextStyle(fontSize: 10, color: colors[level])), // ← FontSize 10
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.beachId.replaceAll(RegExp(r'-+'), '-');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap, // ← CLIC SUR TOUTE LA CARTE
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === IMAGE COLLÉE À GAUCHE, PLEINE HAUTEUR ===
              Container(
                width: 80,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/${imagePath}-min.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.grey, size: 32),
                        );
                      },
                    )),
              ),

              // === CONTENU À DROITE ===
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Titre
                      Text(
                        widget.beachName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Rapport
                      Flexible(
                        // ← Flexible pour s'adapter
                        child: StreamBuilder<List<BeachReport>>(
                          stream: firestore.getReports(widget.beachId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _cachedReports = snapshot.data!;
                            }
                            final reports = _cachedReports ?? [];
                            if (reports.isEmpty) {
                              return const Text("Aucun avis",
                                  style: TextStyle(fontSize: 13));
                            }
                            final report = reports.first;

                            // === FILTRES ===
                            if (widget.filterNoSargasses &&
                                report.sargassesLevel != 0) {
                              return const SizedBox.shrink();
                            }
                            if (widget.filterLowWaves &&
                                report.wavesLevel > 1) {
                              return const SizedBox.shrink();
                            }
                            if (widget.filterLowCrowd &&
                                report.crowdLevel > 1) {
                              return const SizedBox.shrink();
                            }
                            if (widget.filterLowNoise &&
                                report.noiseLevel > 1) {
                              return const SizedBox.shrink();
                            }
                            // === FIN FILTRES ===

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _timeAgo(report.timestamp),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                // Row des icônes — FIXÉE
                                Row(
                                  mainAxisSize:
                                      MainAxisSize.min, // ← FIX : Min space
                                  children: [
                                    _getLevelIcon(
                                        report.sargassesLevel, Icons.eco),
                                    const SizedBox(width: 4), // ← Espace réduit
                                    _getLevelIcon(
                                        report.wavesLevel, Icons.waves),
                                    const SizedBox(width: 4),
                                    _getLevelIcon(
                                        report.crowdLevel, Icons.people),
                                    const SizedBox(width: 4),
                                    _getLevelIcon(
                                        report.noiseLevel, Icons.volume_up),
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
                                    const SizedBox(width: 6),
                                    Text("${reports.length} avis",
                                        style: const TextStyle(fontSize: 12)),
                                    const Spacer(),
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
                                            "${report.comment != null ? 'Quote: \"${report.comment}\"' : ''}");

                                        final url =
                                            'https://wa.me/?text=$message';
                                        launchUrl(Uri.parse(url));
                                      },
                                      child: const Icon(Icons.share,
                                          size: 20, color: Colors.green),
                                    ),
                                  ],
                                ),
                                if (report.comment != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${report.comment}"',
                                    style: TextStyle(
                                      fontSize: 11,
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
                      ),
                    ],
                  ),
                ),
              ),

              // === FLÈCHE À DROITE ===
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child:
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
