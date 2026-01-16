/// Flow State Machine - Onboarding Example
///
/// Demonstrates the Flow-based State Machine pattern for
/// multi-step wizards and onboarding flows.
///
/// ## Key Concepts:
/// 1. Steps are defined as enum (compile-time safety)
/// 2. Transitions are explicit in Bloc (traceable)
/// 3. Effects are emitted as output of transitions
/// 4. State machine is deterministic and testable
///
/// ## Flow Diagram:
/// ```
///  ┌──────────┐    ┌──────────┐    ┌─────────────┐    ┌──────────┐
///  │ Welcome  │───▶│ Profile  │───▶│ Permissions │───▶│ Complete │
///  └──────────┘    └──────────┘    └─────────────┘    └──────────┘
///        │              │                │
///        │              │                │
///        ▼              ▼                ▼
///      [Skip]        [Skip]          [Skip]
/// ```
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/bloc.dart';

// ============================================================================
// Step Enum - The State Machine Definition
// ============================================================================

/// All possible steps in the onboarding flow
enum OnboardingStep {
  /// Initial welcome screen
  welcome,

  /// User profile setup
  profile,

  /// Permission requests (notifications, health, etc.)
  permissions,

  /// Completion screen
  complete,
}

/// Extension for step metadata and transitions
extension OnboardingStepX on OnboardingStep {
  /// Get the next step in the flow
  OnboardingStep? get next => switch (this) {
        OnboardingStep.welcome => OnboardingStep.profile,
        OnboardingStep.profile => OnboardingStep.permissions,
        OnboardingStep.permissions => OnboardingStep.complete,
        OnboardingStep.complete => null,
      };

  /// Get the previous step
  OnboardingStep? get previous => switch (this) {
        OnboardingStep.welcome => null,
        OnboardingStep.profile => OnboardingStep.welcome,
        OnboardingStep.permissions => OnboardingStep.profile,
        OnboardingStep.complete => OnboardingStep.permissions,
      };

  /// Check if step can be skipped
  bool get isSkippable => switch (this) {
        OnboardingStep.welcome => false,
        OnboardingStep.profile => true,
        OnboardingStep.permissions => true,
        OnboardingStep.complete => false,
      };

  /// Check if this is the final step
  bool get isFinal => this == OnboardingStep.complete;

  /// Progress percentage (0.0 to 1.0)
  double get progress => switch (this) {
        OnboardingStep.welcome => 0.0,
        OnboardingStep.profile => 0.33,
        OnboardingStep.permissions => 0.66,
        OnboardingStep.complete => 1.0,
      };
}

// ============================================================================
// Events
// ============================================================================

/// Base event for onboarding flow
sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Start the onboarding flow
final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

/// Complete the current step and proceed
final class OnboardingStepCompleted extends OnboardingEvent {
  /// The step that was completed
  final OnboardingStep step;

  /// Optional data from the step
  final Map<String, dynamic>? stepData;

  const OnboardingStepCompleted({
    required this.step,
    this.stepData,
  });

  @override
  List<Object?> get props => [step, stepData];
}

/// Skip the current step
final class OnboardingStepSkipped extends OnboardingEvent {
  /// The step that was skipped
  final OnboardingStep step;

  const OnboardingStepSkipped({required this.step});

  @override
  List<Object?> get props => [step];
}

/// Go back to previous step
final class OnboardingStepBack extends OnboardingEvent {
  const OnboardingStepBack();
}

/// Finish onboarding and navigate to main app
final class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}

// ============================================================================
// State
// ============================================================================

/// Onboarding flow state
final class OnboardingState extends UiState with EffectClearable<OnboardingState> {
  /// Current step in the flow
  final OnboardingStep currentStep;

  /// Collected data from completed steps
  final Map<String, dynamic> collectedData;

  /// Steps that have been completed
  final Set<OnboardingStep> completedSteps;

  /// Steps that were skipped
  final Set<OnboardingStep> skippedSteps;

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.collectedData = const {},
    this.completedSteps = const {},
    this.skippedSteps = const {},
    super.effect,
  });

  /// Initial state factory
  factory OnboardingState.initial() => const OnboardingState();

  /// Check if can go back
  bool get canGoBack => currentStep.previous != null;

  /// Check if current step was already completed
  bool get isCurrentStepCompleted => completedSteps.contains(currentStep);

  /// Get progress (0.0 to 1.0)
  double get progress => currentStep.progress;

  @override
  List<Object?> get props => [
        currentStep,
        collectedData,
        completedSteps,
        skippedSteps,
        // Note: effect is NOT included (inherited from UiState)
      ];

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    Map<String, dynamic>? collectedData,
    Set<OnboardingStep>? completedSteps,
    Set<OnboardingStep>? skippedSteps,
    UiEffect? effect,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      collectedData: collectedData ?? this.collectedData,
      completedSteps: completedSteps ?? this.completedSteps,
      skippedSteps: skippedSteps ?? this.skippedSteps,
      effect: effect,
    );
  }

  @override
  OnboardingState clearEffect() => copyWith(effect: null);

  @override
  OnboardingState withEffect(UiEffect? effect) => copyWith(effect: effect);
}

// ============================================================================
// Bloc
// ============================================================================

/// Onboarding flow bloc
///
/// Manages the state machine for onboarding wizard.
class OnboardingBloc extends EffectBloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState.initial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingStepCompleted>(_onStepCompleted);
    on<OnboardingStepSkipped>(_onStepSkipped);
    on<OnboardingStepBack>(_onStepBack);
    on<OnboardingFinished>(_onFinished);
  }

  /// Handle flow start
  void _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) {
    // Already at welcome, just ensure clean state
    emit(OnboardingState.initial());
  }

  /// Handle step completion
  void _onStepCompleted(
    OnboardingStepCompleted event,
    Emitter<OnboardingState> emit,
  ) {
    // Validate we're on the expected step
    if (state.currentStep != event.step) {
      emitWithEffect(
        emit,
        state,
        ShowSnackBarEffect(
          message: 'Invalid step transition',
          severity: FeedbackSeverity.error,
        ),
      );
      return;
    }

    // Get next step
    final nextStep = event.step.next;

    if (nextStep == null) {
      // No next step - flow complete
      add(const OnboardingFinished());
      return;
    }

    // Merge step data
    final newCollectedData = {
      ...state.collectedData,
      if (event.stepData != null) event.step.name: event.stepData,
    };

    // Mark step as completed
    final newCompletedSteps = {...state.completedSteps, event.step};

    // Transition to next step
    emit(state.copyWith(
      currentStep: nextStep,
      collectedData: newCollectedData,
      completedSteps: newCompletedSteps,
    ));
  }

  /// Handle step skip
  void _onStepSkipped(
    OnboardingStepSkipped event,
    Emitter<OnboardingState> emit,
  ) {
    // Validate step is skippable
    if (!event.step.isSkippable) {
      emitWithEffect(
        emit,
        state,
        ShowSnackBarEffect(
          message: 'This step cannot be skipped',
          severity: FeedbackSeverity.warning,
        ),
      );
      return;
    }

    // Get next step
    final nextStep = event.step.next;

    if (nextStep == null) {
      add(const OnboardingFinished());
      return;
    }

    // Mark step as skipped
    final newSkippedSteps = {...state.skippedSteps, event.step};

    // Transition to next step
    emit(state.copyWith(
      currentStep: nextStep,
      skippedSteps: newSkippedSteps,
    ));
  }

  /// Handle back navigation
  void _onStepBack(
    OnboardingStepBack event,
    Emitter<OnboardingState> emit,
  ) {
    final previousStep = state.currentStep.previous;

    if (previousStep == null) {
      // Can't go back from first step
      return;
    }

    emit(state.copyWith(currentStep: previousStep));
  }

  /// Handle flow completion
  void _onFinished(
    OnboardingFinished event,
    Emitter<OnboardingState> emit,
  ) {
    // Emit success message and navigation
    emitWithEffect(
      emit,
      state.copyWith(currentStep: OnboardingStep.complete),
      NavigateReplaceEffect(route: '/home'),
    );
  }
}
