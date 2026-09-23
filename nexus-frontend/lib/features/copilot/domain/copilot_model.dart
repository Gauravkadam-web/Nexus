class CopilotCitationModel {
  final String sourceTitle;
  final String? snippet;
  final double? relevanceScore;

  const CopilotCitationModel({
    required this.sourceTitle,
    this.snippet,
    this.relevanceScore,
  });

  factory CopilotCitationModel.fromJson(Map<String, dynamic> json) {
    return CopilotCitationModel(
      sourceTitle: json['sourceTitle'] as String? ?? json['title'] as String? ?? json['source'] as String? ?? 'System Knowledge',
      snippet: json['snippet'] as String?,
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble(),
    );
  }
}

class CopilotQueryResponse {
  final String answer;
  final double confidence;
  final List<String> sources;
  final List<CopilotCitationModel> citations;
  final List<String> suggestedActions;

  const CopilotQueryResponse({
    required this.answer,
    required this.confidence,
    this.sources = const [],
    this.citations = const [],
    this.suggestedActions = const [],
  });

  factory CopilotQueryResponse.fromJson(Map<String, dynamic> json) {
    final rawSources = (json['sources'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    List<CopilotCitationModel> cList = [];
    if (json['citations'] is List) {
      cList = (json['citations'] as List<dynamic>)
          .map((e) => e is Map<String, dynamic>
              ? CopilotCitationModel.fromJson(e)
              : CopilotCitationModel(sourceTitle: e.toString()))
          .toList();
    } else if (rawSources.isNotEmpty) {
      cList = rawSources.map((s) => CopilotCitationModel(sourceTitle: s)).toList();
    }

    return CopilotQueryResponse(
      answer: json['answer'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      sources: rawSources,
      citations: cList,
      suggestedActions: (json['suggestedActions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CommunicationDraftResponse {
  final String draftText;
  final String tone;
  final String? audience;
  final List<String> suggestedRecipients;

  const CommunicationDraftResponse({
    required this.draftText,
    required this.tone,
    this.audience,
    this.suggestedRecipients = const [],
  });

  factory CommunicationDraftResponse.fromJson(Map<String, dynamic> json) {
    return CommunicationDraftResponse(
      draftText: json['draftText'] as String? ?? '',
      tone: json['tone'] as String? ?? 'PROFESSIONAL',
      audience: json['audience'] as String?,
      suggestedRecipients: (json['suggestedRecipients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
