class ReportModel {
  final String id;
  final String result;
  final double confidence;
  final DateTime date;
  final String pdfPath;

  ReportModel({
    required this.id,
    required this.result,
    required this.confidence,
    required this.date,
    required this.pdfPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'result': result,
      'confidence': confidence,
      'date': date.toIso8601String(),
      'pdfPath': pdfPath,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      result: json['result'],
      confidence: (json['confidence'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      pdfPath: json['pdfPath'],
    );
  }
}