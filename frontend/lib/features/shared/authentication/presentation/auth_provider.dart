import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool hasCompletedSplash;
  final bool hasSeenOnboarding;
  final String? errorMessage;
  final String? email;
  final String role; // 'Admin' or 'Driver' / 'User'

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.hasCompletedSplash = false,
    this.hasSeenOnboarding = false,
    this.errorMessage,
    this.email,
    this.role = 'Admin',
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? hasCompletedSplash,
    bool? hasSeenOnboarding,
    String? errorMessage,
    String? email,
    String? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedSplash: hasCompletedSplash ?? this.hasCompletedSplash,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      errorMessage: errorMessage,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void completeSplash() {
    state = state.copyWith(hasCompletedSplash: true);
  }

  void completeOnboarding() {
    state = state.copyWith(hasSeenOnboarding: true);
  }

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

    final determinedRole = email.toLowerCase().contains('admin') ? 'Admin' : role;

    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      hasCompletedSplash: true,
      hasSeenOnboarding: true,
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
      hasCompletedSplash: true,
      hasSeenOnboarding: true,
      email: email,
      role: determinedRole,
    );
    return true;
  }

  void logout() {
    state = state.copyWith(
      isAuthenticated: false,
      errorMessage: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
