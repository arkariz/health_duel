import 'package:health_duel/core/bloc/bloc.dart';

final class NavigatePopEffect extends NavigationEffect {
  final Object? result;

  const NavigatePopEffect({this.result});

  @override
  List<Object?> get props => [result];
}