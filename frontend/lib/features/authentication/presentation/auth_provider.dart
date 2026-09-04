import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? email;
  final String role; // 'Admin' or 'User'

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.email,
    this.role = 'Admin',
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? email,
    String? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password, {String role = 'Admin'}) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid email address format',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Password must be at least 6 characters long',
      );
      return false;
    }

    // Determine role from email or explicit role
    final determinedRole = email.toLowerCase().contains('admin') ? 'Admin' : role;

    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      email: email,
      role: determinedRole,
    );
    return true;
  }

  Future<bool> signUp(String email, String password, {String role = 'User'}) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid email address format',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Password must be at least 6 characters long',
      );
      return false;
    }

    final determinedRole = email.toLowerCase().contains('admin') ? 'Admin' : role;

    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      email: email,
      role: determinedRole,
    );
    return true;
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
