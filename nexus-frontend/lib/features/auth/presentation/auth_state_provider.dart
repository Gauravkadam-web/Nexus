import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.login(email: email, password: password);
    if (result.success && result.user != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  Future<bool> loginAsDemoRole(String roleName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    String email;
    const password = 'Password123!';
    UserModel fallbackUser;

    switch (roleName.toUpperCase()) {
      case 'REQUESTER':
        email = 'requester@nexus.com';
        fallbackUser = const UserModel(
          id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          email: 'requester@nexus.com',
          name: 'Sarah Connor',
          organizationName: 'Acme Global Operations',
          roles: ['REQUESTER'],
        );
        break;
      case 'OPERATOR':
      case 'CASE_OPERATOR':
        email = 'operator@nexus.com';
        fallbackUser = const UserModel(
          id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
          email: 'operator@nexus.com',
          name: 'Elena Vance',
          organizationName: 'Acme Global Operations',
          roles: ['OPERATOR'],
        );
        break;
      case 'TEAM_LEAD':
        email = 'lead@nexus.com';
        fallbackUser = const UserModel(
          id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
          email: 'lead@nexus.com',
          name: 'Marcus Brody',
          organizationName: 'Acme Global Operations',
          roles: ['TEAM_LEAD'],
        );
        break;
      case 'MANAGER':
        email = 'problem.manager@nexus.com';
        fallbackUser = const UserModel(
          id: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
          email: 'problem.manager@nexus.com',
          name: 'Rachel Sterling',
          organizationName: 'Acme Global Operations',
          roles: ['MANAGER'],
        );
        break;
      case 'ADMIN':
      case 'ADMINISTRATOR':
      default:
        email = 'admin@nexus.com';
        fallbackUser = const UserModel(
          id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
          email: 'admin@nexus.com',
          name: 'Gaurav Kadam',
          organizationName: 'Acme Global Operations',
          roles: ['ADMIN'],
        );
        break;
    }

    // Try real backend login first
    final result = await _repository.login(email: email, password: password);
    if (result.success && result.user != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
      );
      return true;
    }

    // Fallback to demo user state if offline
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: fallbackUser,
      errorMessage: null,
    );
    return true;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
