import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';

/// Register Page with Phase 3.5 patterns
///
/// Features:
/// - [EffectListener] for navigation and snackbar (ADR-004)
/// - [AnimatedOfflineBanner] for connectivity status
/// - [ValidatedTextField] with real-time validation
/// - [PasswordTextField] with visibility toggle
/// - [ConstrainedContent] for responsive layout
/// - [Shimmer] skeleton loading
/// - [context.responsiveValue] for adaptive sizing
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          // Offline banner at top
          const AnimatedOfflineBanner(),

          // Main content with EffectListener
          Expanded(
            child: EffectListener<AuthBloc, AuthState>(
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen:
                    (prev, curr) =>
                        prev.runtimeType != curr.runtimeType ||
                        (prev is AuthLoading && curr is AuthLoading && prev.message != curr.message),
                builder: (context, state) {
                  // Show skeleton during loading
                  if (state is AuthLoading) {
                    return _LoadingView(message: state.message);
                  }

                  return _RegisterForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    onRegister: _register,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading view with skeleton
class _LoadingView extends StatelessWidget {
  const _LoadingView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedContent(
          maxWidth: 480,
          child: Shimmer(
            child: Padding(
              padding: EdgeInsets.all(context.horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon skeleton
                  SkeletonCircle(size: context.responsiveValue(phone: 64.0, tablet: 80.0, desktop: 96.0)),
                  const SizedBox(height: 16),
                  const SkeletonText(width: 180, height: 32),
                  const SizedBox(height: 8),
                  const SkeletonText(width: 240),
                  SizedBox(height: context.responsiveValue(phone: 32.0, tablet: 40.0, desktop: 48.0)),

                  // Form skeleton (4 fields for register)
                  const SkeletonBox(height: 56),
                  const SizedBox(height: 16),
                  const SkeletonBox(height: 56),
                  const SizedBox(height: 16),
                  const SkeletonBox(height: 56),
                  const SizedBox(height: 16),
                  const SkeletonBox(height: 56),
                  const SizedBox(height: 24),

                  // Loading indicator
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    message ?? 'Creating your account...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Register form with validation
class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 24),
      child: ConstrainedContent(
        maxWidth: 480,
        padding: EdgeInsets.zero,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.responsiveValue(phone: 24.0, tablet: 40.0, desktop: 56.0)),

              // Icon/Title
              Icon(
                Icons.person_add_outlined,
                size: context.responsiveValue(phone: 64.0, tablet: 80.0, desktop: 96.0),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Join Health Duel',
                style: context
                    .responsiveValue(
                      phone: theme.textTheme.headlineMedium,
                      tablet: theme.textTheme.headlineLarge,
                      desktop: theme.textTheme.displaySmall,
                    )
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to start challenging friends',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.responsiveValue(phone: 32.0, tablet: 40.0, desktop: 48.0)),

              // Name field
              ValidatedTextField(
                controller: nameController,
                label: 'Full Name',
                keyboardType: TextInputType.name,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: FormValidators.required,
              ),
              const SizedBox(height: 16),

              // Email field with real-time validation
              ValidatedTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: FormValidators.email,
              ),
              const SizedBox(height: 16),

              // Password field with visibility toggle
              PasswordTextField(
                controller: passwordController,
                label: 'Password',
                textInputAction: TextInputAction.next,
                validator: (value) => FormValidators.password(value, minLength: 6),
              ),
              const SizedBox(height: 16),

              // Confirm password field
              PasswordTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onRegister(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Register button
              FilledButton(
                onPressed: onRegister,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 24),

              // Terms and conditions hint
              Text(
                'By creating an account, you agree to our Terms of Service and Privacy Policy',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: theme.textTheme.bodyMedium),
                  TextButton(onPressed: () => context.pop(), child: const Text('Sign In')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
