class BeachReport {
  final String beachId;
  final String beachName;
  final bool hasSargasses;
  final bool hasWaves;
  final bool isCrowded;
  final bool isNoisy;
  final int rating;
  final String? comment;
  final DateTime timestamp;

  BeachReport({
    required this.beachId,
    required this.beachName,
    required this.hasSargasses,
    required this.hasWaves,
    required this.isCrowded,
    required this.isNoisy,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'beachId': beachId,
        'beachName': beachName,
        'hasSargasses': hasSargasses,
        'hasWaves': hasWaves,
        'isCrowded': isCrowded,
        'isNoisy': isNoisy,
        'rating': rating,
        'comment': comment,
        'timestamp': timestamp.toIso8601String(),
      };

  factory BeachReport.fromJson(Map<String, dynamic> json) => BeachReport(
        beachId: json['beachId'],
        beachName: json['beachName'],
        hasSargasses: json['hasSargasses'],
        hasWaves: json['hasWaves'],
        isCrowded: json['isCrowded'],
        isNoisy: json['isNoisy'],
        rating: json['rating'],
        comment: json['comment'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}