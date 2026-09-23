import '../domain/admin_models.dart';
import 'admin_api.dart';

class AdminRepository {
  final AdminApi _api = AdminApi();

  Future<({bool success, List<AdminUserModel> users, String? error})> getUsers() async {
    final res = await _api.getUsers();
    if (res.success && res.data != null) {
      return (success: true, users: res.data!, error: null);
    }
    return (success: false, users: <AdminUserModel>[], error: res.error);
  }

  Future<({bool success, String? error})> updateUserRole({
    required String userId,
    required String role,
  }) async {
    final res = await _api.updateUserRole(userId: userId, role: role);
    if (res.success) {
      return (success: true, error: null);
    }
    return (success: false, error: res.error);
  }

  Future<({bool success, List<SlaPolicyModel> policies, String? error})> getSlaPolicies() async {
    final res = await _api.getSlaPolicies();
    if (res.success && res.data != null) {
      return (success: true, policies: res.data!, error: null);
    }
    return (success: false, policies: <SlaPolicyModel>[], error: res.error);
  }

  Future<({bool success, List<CategoryModel> categories, String? error})> getCategories() async {
    final res = await _api.getCategories();
    if (res.success && res.data != null) {
      return (success: true, categories: res.data!, error: null);
    }
    return (success: false, categories: <CategoryModel>[], error: res.error);
  }

  Future<({bool success, List<TeamModel> teams, String? error})> getTeams() async {
    final res = await _api.getTeams();
    if (res.success && res.data != null) {
      return (success: true, teams: res.data!, error: null);
    }
    return (success: false, teams: <TeamModel>[], error: res.error);
  }
}
