class BeachReport {
  final String beachId;
  final String beachName;
  final int sargassesLevel; // ← 0 à 3
  final int wavesLevel;     // ← 0 à 3
  final int crowdLevel;     // ← 0 à 3
  final int noiseLevel;     // ← 0 à 3
  final int rating;
  final String? comment;
  final DateTime timestamp;

  BeachReport({
    required this.beachId,
    required this.beachName,
    required this.sargassesLevel,
    required this.wavesLevel,
    required this.crowdLevel,
    required this.noiseLevel,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'beachId': beachId,
        'beachName': beachName,
        'sargassesLevel': sargassesLevel,
        'wavesLevel': wavesLevel,
        'crowdLevel': crowdLevel,
        'noiseLevel': noiseLevel,
        'rating': rating,
        'comment': comment,
        'timestamp': timestamp.toIso8601String(),
      };

  factory BeachReport.fromJson(Map<String, dynamic> json) => BeachReport(
        beachId: json['beachId'],
        beachName: json['beachName'],
        sargassesLevel: json['sargassesLevel'],
        wavesLevel: json['wavesLevel'],
        crowdLevel: json['crowdLevel'],
        noiseLevel: json['noiseLevel'],
        rating: json['rating'],
        comment: json['comment'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}