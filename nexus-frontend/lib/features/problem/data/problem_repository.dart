import '../domain/problem_model.dart';
import 'problem_api.dart';

class ProblemRepository {
  final ProblemApi _api = ProblemApi();

  Future<({bool success, List<ProblemModel> problems, String? error})> getProblems() async {
    final res = await _api.getProblems();
    if (res.success && res.data != null) {
      return (success: true, problems: res.data!, error: null);
    }
    return (success: false, problems: <ProblemModel>[], error: res.error);
  }

  Future<({bool success, ProblemModel? problem, String? error})> getProblemDetail(String id) async {
    final res = await _api.getProblemDetail(id);
    if (res.success && res.data != null) {
      return (success: true, problem: res.data, error: null);
    }
    return (success: false, problem: null, error: res.error);
  }

  Future<({bool success, List<RecurringPatternModel> patterns, String? error})> getRecurringPatterns() async {
    final res = await _api.getRecurringPatterns();
    if (res.success && res.data != null) {
      return (success: true, patterns: res.data!, error: null);
    }
    return (success: false, patterns: <RecurringPatternModel>[], error: res.error);
  }

  Future<({bool success, String? error})> linkIncident({
    required String problemId,
    required String caseId,
  }) async {
    final res = await _api.linkIncident(problemId: problemId, caseId: caseId);
    if (res.success) {
      return (success: true, error: null);
    }
    return (success: false, error: res.error);
  }
}
