// lib/widgets/beach_card.dart
import 'package:flutter/material.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';

class BeachCard extends StatefulWidget {
  final String beachName;
  final String beachId; // ← ON LE PASSE DIRECT
  final VoidCallback onTap;

  const BeachCard({
    super.key,
    required this.beachName,
    required this.beachId,
    required this.onTap,
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

  Widget _getIcon(bool condition, IconData iconTrue, IconData iconFalse) {
    return Icon(
      condition ? iconTrue : iconFalse,
      color: condition ? Colors.red : Colors.green,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            widget.beachName[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(widget.beachName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: StreamBuilder<List<BeachReport>>(
          stream: firestore.getReports(widget.beachId), // ← beachId propre
          builder: (context, snapshot) {
            // MAJ du cache
            if (snapshot.hasData) {
              _cachedReports = snapshot.data!;
            }

            final reports = _cachedReports ?? [];
            if (reports.isEmpty) {
              return const Text("Aucun avis");
            }

            final report = reports.first;

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
                    _getIcon(report.hasSargasses, Icons.eco, Icons.eco_outlined),
                    const SizedBox(width: 8),
                    _getIcon(report.hasWaves, Icons.waves, Icons.waves_outlined),
                    const SizedBox(width: 8),
                    _getIcon(report.isCrowded, Icons.people, Icons.person_outline),
                    const SizedBox(width: 8),
                    _getIcon(report.isNoisy, Icons.volume_up, Icons.volume_off),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                          i < report.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        )),
                    const Spacer(),
                    Text("${reports.length} avis"),
                  ],
                ),
              ],
            );
          },
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: widget.onTap,
      ),
    );
  }
}