enum DialogAction { confirm, cancel, destructive, neutral }
enum DialogIcon { info, success, warning, error, question }

/// Dialog action button configuration
class DialogActionConfig {
  final DialogAction action;
  final String? label;
  final bool isPrimary;

  const DialogActionConfig({
    required this.action,
    this.label,
    this.isPrimary = false,
  });

  String get defaultLabel => switch (action) {
    DialogAction.confirm => 'OK',
    DialogAction.cancel => 'Cancel',
    DialogAction.destructive => 'Delete',
    DialogAction.neutral => 'Skip',
  };

  String get effectiveLabel => label ?? defaultLabel;
}