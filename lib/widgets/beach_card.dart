import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/beach_report.dart';

class BeachCard extends StatelessWidget {
  final String beachName;
  final VoidCallback onTap;

  const BeachCard({super.key, required this.beachName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(beachName),
        subtitle: StreamBuilder<List<BeachReport>>(
          stream: firestore.getReports(beachName.toLowerCase().replaceAll(' ', '-')),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No reports yet');
            }
            final report = snapshot.data!.first;
            return Text(
              'Latest: ${report.hasSargasses ? "Sargasses" : "No Sargasses"}, '
              '${report.rating} stars, ${report.timestamp.hour}:${report.timestamp.minute}',
            );
          },
        ),
        onTap: onTap,
      ),
    );
  }
}