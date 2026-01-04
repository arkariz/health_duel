import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/auth/domain/usecases/get_current_user.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_out.dart';
import 'package:health_duel/features/home/presentation/bloc/home_event.dart';
import 'package:health_duel/features/home/presentation/bloc/home_state.dart';

/// Home Bloc - Manages home screen state
///
/// Uses Pattern A: Single State with Clear Partitioning
///
/// State uses single [HomeState] class with:
/// - [HomeStatus] enum for state transitions
/// - Renderable data (user, errorMessage) in props
/// - Side-effect triggers (effect) NOT in props
///
/// Uses generic effects from core:
/// - [NavigateGoEffect] → For navigation after sign out
/// - [ShowSnackBarEffect] → For error/success messages
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentUser _getCurrentUser;
  final SignOut _signOut;

  HomeBloc({required GetCurrentUser getCurrentUser, required SignOut signOut})
    : _getCurrentUser = getCurrentUser,
      _signOut = signOut,
      super(const HomeState()) {
    on<HomeLoadUserRequested>(_onLoadUserRequested);
    on<HomeSignOutRequested>(_onSignOutRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  /// Load current user data
  Future<void> _onLoadUserRequested(HomeLoadUserRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, loadingMessage: 'Loading your profile...', clearError: true));

    final result = await _getCurrentUser();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
          effect: ShowSnackBarEffect(message: failure.message, severity: FeedbackSeverity.error),
        ),
      ),
      (user) {
        if (user != null) {
          emit(state.copyWith(status: HomeStatus.loaded, user: user, clearError: true));
        } else {
          // User not logged in, navigate to login
          emit(
            state.copyWith(
              status: HomeStatus.failure,
              errorMessage: 'Not authenticated',
              effect: const NavigateGoEffect(route: '/login'),
            ),
          );
        }
      },
    );
  }

  /// Sign out and navigate to login
  Future<void> _onSignOutRequested(HomeSignOutRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, loadingMessage: 'Signing out...'));

    final result = await _signOut();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.loaded, // Stay on loaded state
          effect: ShowSnackBarEffect(message: failure.message, severity: FeedbackSeverity.error),
        ),
      ),
      (_) => emit(
        state.copyWith(status: HomeStatus.initial, clearUser: true, effect: const NavigateGoEffect(route: '/login')),
      ),
    );
  }

  /// Refresh user data (pull-to-refresh)
  Future<void> _onRefreshRequested(HomeRefreshRequested event, Emitter<HomeState> emit) async {
    // Keep current state while refreshing (no loading indicator)
    final result = await _getCurrentUser();

    result.fold(
      (failure) => emit(
        state.copyWith(
          effect: ShowSnackBarEffect(
            message: 'Failed to refresh: ${failure.message}',
            severity: FeedbackSeverity.warning,
          ),
        ),
      ),
      (user) {
        if (user != null) {
          emit(state.copyWith(status: HomeStatus.loaded, user: user));
        }
      },
    );
  }
}
