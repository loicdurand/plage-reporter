import 'package:flutter/material.dart';
import '../models/beach_report.dart';
import '../services/firestore_service.dart';

class ReportScreen extends StatefulWidget {
  final String? beachName;
  const ReportScreen({super.key, this.beachName});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool hasSargasses = false;
  bool hasWaves = false;
  bool isCrowded = false;
  bool isNoisy = false;
  int rating = 3;
  final commentController = TextEditingController();
  String? selectedBeach;

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Report Conditions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<List<String>>(
              stream: firestore.getBeachNames(),
              builder: (context, snapshot) {
                return DropdownButton<String>(
                  hint: Text(widget.beachName ?? 'Select a beach'),
                  value: selectedBeach,
                  items: snapshot.data
                      ?.map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedBeach = value),
                );
              },
            ),
            CheckboxListTile(
              title: const Text('Sargasses Present'),
              value: hasSargasses,
              onChanged: (value) => setState(() => hasSargasses = value!),
            ),
            CheckboxListTile(
              title: const Text('Waves'),
              value: hasWaves,
              onChanged: (value) => setState(() => hasWaves = value!),
            ),
            CheckboxListTile(
              title: const Text('Crowded'),
              value: isCrowded,
              onChanged: (value) => setState(() => isCrowded = value!),
            ),
            CheckboxListTile(
              title: const Text('Noisy'),
              value: isNoisy,
              onChanged: (value) => setState(() => isNoisy = value!),
            ),
            Slider(
              value: rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$rating stars',
              onChanged: (value) => setState(() => rating = value.toInt()),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Comment (optional)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedBeach == null
                  ? null
                  : () {
                      firestore.addReport(BeachReport(
                        beachId: selectedBeach!.toLowerCase().replaceAll(' ', '-'),
                        beachName: selectedBeach!,
                        hasSargasses: hasSargasses,
                        hasWaves: hasWaves,
                        isCrowded: isCrowded,
                        isNoisy: isNoisy,
                        rating: rating,
                        comment: commentController.text.isEmpty ? null : commentController.text,
                        timestamp: DateTime.now(),
                      ));
                      Navigator.pop(context);
                    },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}