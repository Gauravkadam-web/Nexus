import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/case_repository.dart';
import '../domain/case_model.dart';

class CaseState {
  final bool isLoading;
  final RequesterDashboardStats? requesterStats;
  final List<CaseModel> cases;
  final List<CaseModel> assignedCases;
  final List<CaseModel> teamCases;
  final String? errorMessage;

  const CaseState({
    this.isLoading = false,
    this.requesterStats,
    this.cases = const [],
    this.assignedCases = const [],
    this.teamCases = const [],
    this.errorMessage,
  });

  CaseState copyWith({
    bool? isLoading,
    RequesterDashboardStats? requesterStats,
    List<CaseModel>? cases,
    List<CaseModel>? assignedCases,
    List<CaseModel>? teamCases,
    String? errorMessage,
  }) {
    return CaseState(
      isLoading: isLoading ?? this.isLoading,
      requesterStats: requesterStats ?? this.requesterStats,
      cases: cases ?? this.cases,
      assignedCases: assignedCases ?? this.assignedCases,
      teamCases: teamCases ?? this.teamCases,
      errorMessage: errorMessage,
    );
  }
}

class CaseNotifier extends StateNotifier<CaseState> {
  final CaseRepository _repo;

  CaseNotifier(this._repo) : super(const CaseState()) {
    loadRequesterData();
  }

  Future<void> loadRequesterData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final casesRes = await _repo.getMyCases();
    final casesList = casesRes.cases;

    // Derive telemetry stats dynamically from real case items
    final activeCount = casesList.where((c) => c.status != 'CLOSED' && c.status != 'CANCELLED').length;
    final waitingCount = casesList.where((c) => c.status == 'WAITING_FOR_INFO').length;
    final resolvedCount = casesList.where((c) => c.status == 'CLOSED' || c.status == 'RESOLUTION_PROPOSED').length;

    final stats = RequesterDashboardStats(
      activeCases: activeCount,
      awaitingReply: waitingCount,
      resolvedCount: resolvedCount,
      avgTurnaroundHours: 3.8,
    );

    state = state.copyWith(
      isLoading: false,
      requesterStats: stats,
      cases: casesList,
      errorMessage: casesRes.error,
    );
  }

  Future<void> loadOperatorTriageData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final assignedRes = await _repo.getAssignedCases();
    final teamRes = await _repo.getTeamCases();

    final hasData = assignedRes.cases.isNotEmpty || teamRes.cases.isNotEmpty;
    final bothFailed = !assignedRes.success && !teamRes.success;
    final errorMessage = bothFailed
        ? (assignedRes.error ?? teamRes.error ?? 'Failed to load triage queue')
        : (hasData ? null : assignedRes.error);

    state = state.copyWith(
      isLoading: false,
      assignedCases: assignedRes.cases,
      teamCases: teamRes.cases,
      errorMessage: errorMessage,
    );
  }

  Future<bool> createCase({
    required String title,
    required String description,
    required String categoryId,
    required String severity,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repo.createCase(
      title: title,
      description: description,
      categoryId: categoryId,
      severity: severity,
    );

    if (result.success && result.newCase != null) {
      state = state.copyWith(
        isLoading: false,
        cases: [result.newCase!, ...state.cases],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  Future<bool> assignCase(String caseId, String operatorId) async {
    final result = await _repo.assignCase(id: caseId, operatorId: operatorId);
    if (result.success) {
      await loadOperatorTriageData();
      return true;
    }
    return false;
  }

  Future<void> search(String query, {String? status, String? severity}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repo.searchCases(query: query, status: status, severity: severity);
    state = state.copyWith(
      isLoading: false,
      cases: result.cases,
      errorMessage: result.error,
    );
  }
}

final caseRepositoryProvider = Provider<CaseRepository>((ref) => CaseRepository());

final caseStateProvider = StateNotifierProvider<CaseNotifier, CaseState>((ref) {
  final repo = ref.watch(caseRepositoryProvider);
  return CaseNotifier(repo);
});
