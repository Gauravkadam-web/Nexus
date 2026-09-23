class ProblemModel {
  final String id;
  final String title;
  final String description;
  final String status; // IDENTIFIED, INVESTIGATING, KNOWN_ERROR, RESOLVED, CLOSED
  final String? rootCause;
  final String? workaround;
  final String? permanentFix;
  final int incidentCount;
  final DateTime createdAt;

  const ProblemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.rootCause,
    this.workaround,
    this.permanentFix,
    this.incidentCount = 0,
    required this.createdAt,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'IDENTIFIED',
      rootCause: json['rootCause'] as String?,
      workaround: json['workaround'] as String?,
      permanentFix: json['permanentFix'] as String?,
      incidentCount: (json['incidentCount'] as num?)?.toInt() ?? (json['linkedCasesCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class RecurringPatternModel {
  final String clusterName;
  final int caseCount;
  final String primaryCategory;
  final double similarityScore;
  final List<String> sampleCaseTitles;

  const RecurringPatternModel({
    required this.clusterName,
    required this.caseCount,
    required this.primaryCategory,
    required this.similarityScore,
    this.sampleCaseTitles = const [],
  });

  factory RecurringPatternModel.fromJson(Map<String, dynamic> json) {
    return RecurringPatternModel(
      clusterName: json['clusterName'] as String? ?? json['patternName'] as String? ?? 'Recurring Pattern',
      caseCount: (json['caseCount'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 1,
      primaryCategory: json['primaryCategory'] as String? ?? json['category'] as String? ?? 'Network',
      similarityScore: (json['similarityScore'] as num?)?.toDouble() ?? 0.88,
      sampleCaseTitles: (json['sampleCaseTitles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
