import 'package:get_it/get_it.dart';
import 'package:health_duel/features/auth/domain/usecases/get_current_user.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_out.dart';
import 'package:health_duel/features/home/presentation/bloc/home_bloc.dart';

/// Register Home feature dependencies
///
/// HomeBloc depends on auth use cases (GetCurrentUser, SignOut)
/// which are already registered by auth module.
void registerHomeModule(GetIt getIt) {
  // ═══════════════════════════════════════════════════════════════════════
  // Presentation - BLoC
  // ═══════════════════════════════════════════════════════════════════════
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getCurrentUser: getIt<GetCurrentUser>(),
      signOut: getIt<SignOut>(),
    ),
  );
}
