import 'package:get_it/get_it.dart';
import 'package:health_duel/features/auth/auth.dart';

GetCurrentUser get getCurrentUser => GetIt.instance<GetCurrentUser>();
SignInWithEmail get signInWithEmail => GetIt.instance<SignInWithEmail>();
SignInWithGoogle get signInWithGoogle => GetIt.instance<SignInWithGoogle>();
SignInWithApple get signInWithApple => GetIt.instance<SignInWithApple>();
RegisterWithEmail get registerWithEmail => GetIt.instance<RegisterWithEmail>();
SignOut get signOut => GetIt.instance<SignOut>();