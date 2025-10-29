import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/beach_report.dart';

class FirestoreService {
  final CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');

  Future<void> addReport(BeachReport report) async {
    await reports.add(report.toJson());
  }

  Stream<List<BeachReport>> getReports(String beachId) {
    return reports
        .where('beachId', isEqualTo: beachId)
        .orderBy('timestamp', descending: true)
        .limit(3)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                BeachReport.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<String>> getBeachNames() {
    return reports.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc['beachName'] as String)
        .toSet()
        .toList());
  }

  Stream<Map<String, int>> getBeachPopularity() {
    return reports.snapshots().map((snapshot) {
      final Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final name = doc['beachName'] as String;
        counts[name] = (counts[name] ?? 0) + 1;
      }
      return counts;
    });
  }
}
