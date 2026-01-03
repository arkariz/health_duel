import 'package:health_duel/core/bloc/bloc.dart';

final class NavigatePushEffect extends NavigationEffect {
  final String route;
  final Object? arguments;

  const NavigatePushEffect({
    required this.route,
    this.arguments,
  });

  @override
  List<Object?> get props => [route, arguments];
}