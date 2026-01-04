/// Pre-built handlers for common effects
///
/// Call `setupEffectHandlers()` once in main.dart before runApp()
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/theme/theme.dart';

/// Register handlers for navigation, feedback, and dialog effects
void setupEffectHandlers({EffectRegistry? registry}) {
  final effectRegistry = registry ?? globalEffectRegistry;

  effectRegistry
    // Navigation effects
    ..register<NavigateGoEffect>((context, effect) {
      context.go(
        effect.queryParameters != null
            ? Uri(path: effect.route, queryParameters: effect.queryParameters).toString()
            : effect.route,
        extra: effect.arguments,
      );
    })
    ..register<NavigateReplaceEffect>((context, effect) => context.go(effect.route, extra: effect.arguments))
    ..register<NavigatePushEffect>((context, effect) => context.push(effect.route, extra: effect.arguments))
    ..register<NavigatePopEffect>((context, effect) {
      if (context.canPop()) {
        context.pop(effect.result);
      }
    })
    // Snackbar effects
    ..register<ShowSnackBarEffect>((context, effect) {
      _showSnackBar(context, effect.message, effect.severity);
    })
    // Dialog effects
    ..register<ShowDialogEffect>((context, effect) {
      showDialog<DialogAction>(
        context: context,
        barrierDismissible: effect.isDismissible,
        builder: (ctx) => AlertDialog(
          icon: effect.icon != null ? _icon(effect.icon!) : null,
          title: Text(effect.title),
          content: Text(effect.message),
          actions:effect.actions
          .map((config) => TextButton(
              style: TextButton.styleFrom(
                foregroundColor:config.action == DialogAction.destructive ? Theme.of(ctx).colorScheme.error : null,
              ),
              onPressed: () => Navigator.of(ctx).pop(config.action),
              child: Text(config.effectiveLabel),
            ),
          ).toList(),
        ),
      );
    });
}

/// Show snackbar with severity styling
void _showSnackBar(BuildContext context, String message, FeedbackSeverity severity) {
  final theme = Theme.of(context);
  final appColors = theme.extension<AppColorsExtension>() ?? AppColorsExtension.light;

  final (bg, fg) = switch (severity) {
    FeedbackSeverity.success => (appColors.success, Colors.white),
    FeedbackSeverity.warning => (appColors.warning, Colors.white),
    FeedbackSeverity.info => (theme.colorScheme.surfaceContainerHighest, theme.colorScheme.onSurface),
    FeedbackSeverity.error => (theme.colorScheme.error, theme.colorScheme.onError),
  };

  final icon = switch (severity) {
    FeedbackSeverity.success => Icons.check_circle_outline,
    FeedbackSeverity.warning => Icons.warning_amber_rounded,
    FeedbackSeverity.info => Icons.info_outline,
    FeedbackSeverity.error => Icons.error_outline,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: TextStyle(color: fg))),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: fg,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
}

Widget _icon(DialogIcon icon) => Builder(
  builder: (context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.light;
    return switch (icon) {
      DialogIcon.info => const Icon(Icons.info_outline, size: 32),
      DialogIcon.error => Icon(Icons.error_outline, size: 32, color: Theme.of(context).colorScheme.error),
      DialogIcon.success => Icon(Icons.check_circle_outline, size: 32, color: appColors.success),
      DialogIcon.question => const Icon(Icons.help_outline, size: 32),
      DialogIcon.warning => Icon(Icons.warning_amber, size: 32, color: appColors.warning),
    };
  },
);
