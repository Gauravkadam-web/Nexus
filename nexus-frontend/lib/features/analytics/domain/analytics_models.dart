class AnalyticsOverviewModel {
  final int totalCases;
  final int openCases;
  final int resolvedCases;
  final double avgResolutionHours;
  final double slaCompliancePercent;
  final double reopenRate;

  const AnalyticsOverviewModel({
    required this.totalCases,
    required this.openCases,
    required this.resolvedCases,
    required this.avgResolutionHours,
    required this.slaCompliancePercent,
    required this.reopenRate,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      totalCases: (json['totalCases'] as num?)?.toInt() ?? (json['totalInflow'] as num?)?.toInt() ?? 0,
      openCases: (json['openCases'] as num?)?.toInt() ?? 0,
      resolvedCases: (json['resolvedCases'] as num?)?.toInt() ?? 0,
      avgResolutionHours: (json['avgResolutionTimeHours'] as num?)?.toDouble() ??
          (json['avgResolutionHours'] as num?)?.toDouble() ??
          (json['mttrHours'] as num?)?.toDouble() ??
          0.0,
      slaCompliancePercent: (json['slaMetPercentage'] as num?)?.toDouble() ??
          (json['slaCompliancePercent'] as num?)?.toDouble() ??
          0.0,
      reopenRate: (json['reopenedRatePercentage'] as num?)?.toDouble() ??
          (json['reopenRate'] as num?)?.toDouble() ??
          0.0,
    );
  }

}

class VolumeTrendModel {
  final String date;
  final int incoming;
  final int resolved;

  const VolumeTrendModel({
    required this.date,
    required this.incoming,
    required this.resolved,
  });

  factory VolumeTrendModel.fromJson(Map<String, dynamic> json) {
    return VolumeTrendModel(
      date: json['date'] as String? ?? json['day'] as String? ?? '',
      incoming: (json['incoming'] as num?)?.toInt() ?? (json['created'] as num?)?.toInt() ?? 0,
      resolved: (json['resolved'] as num?)?.toInt() ?? 0,
    );
  }
}

class OperationalInsightModel {
  final String title;
  final String description;
  final String severity; // INFO, WARNING, CRITICAL
  final String category;

  const OperationalInsightModel({
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
  });

  factory OperationalInsightModel.fromJson(Map<String, dynamic> json) {
    return OperationalInsightModel(
      title: json['title'] as String? ?? 'Insight',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'INFO',
      category: json['category'] as String? ?? 'Operations',
    );
  }
}
