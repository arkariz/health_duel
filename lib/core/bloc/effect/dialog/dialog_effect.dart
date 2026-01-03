/// Dialog-related effects
library;

import 'package:health_duel/core/bloc/bloc.dart';

/// Show dialog with intent-based actions (no callbacks)
final class ShowDialogEffect extends UiEffect implements InteractiveEffect {
  @override
  final String intentId;

  final String title;
  final String message;
  final List<DialogActionConfig> actions;
  final bool isDismissible;
  final DialogIcon? icon;

  const ShowDialogEffect({
    required this.intentId,
    required this.title,
    required this.message,
    required this.actions,
    this.isDismissible = true,
    this.icon,
  });

  @override
  List<Object?> get props => [
    intentId,
    title,
    message,
    actions.map((a) => a.action).toList(),
    isDismissible,
    icon,
  ];
}
