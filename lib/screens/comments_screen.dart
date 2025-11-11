import 'package:flutter/material.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';

class CommentsScreen extends StatelessWidget {
  final String beachId;
  final String beachName;

  const CommentsScreen({
    super.key,
    required this.beachId,
    required this.beachName,
  });

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    return "il y a ${diff.inDays} j";
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text('Commentaires - $beachName')),
      body: StreamBuilder<List<BeachReport>>(
        stream: firestore.getReports(beachId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun commentaire pour cette plage.'));
          }

          final reports = snapshot.data!
              .where((report) => report.comment != null)
              .toList();

          if (reports.isEmpty) {
            return const Center(child: Text('Aucun commentaire pour cette plage.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text(
                  '"${report.comment}"',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
                subtitle: Text(
                  _timeAgo(report.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}