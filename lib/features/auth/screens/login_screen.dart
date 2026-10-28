import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/routing/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_field.dart';
import '../widgets/social_sign_in_button.dart';

/// Sign in with email + password, Google or Apple.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<bool> Function() action) async {
    final ok = await action();
    if (ok && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _run(() => context.read<AuthProvider>().signIn(_email.text, _password.text));
  }

  Future<void> _forgotPassword() async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (AuthProvider.validateEmail(_email.text) != null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Enter your email above first')));
      return;
    }
    final ok = await auth.sendPasswordReset(_email.text);
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? 'Password reset link sent to ${_email.text.trim()}'
          : (auth.error ?? 'Could not send the reset email')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to find your next hostel',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: AuthProvider.validateEmail,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
              onSubmitted: _submit,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: auth.busy ? null : _forgotPassword,
                child: const Text('Forgot password?'),
              ),
            ),
            if (auth.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(auth.error!,
                    style: const TextStyle(color: AppColors.error)),
              ),
            ElevatedButton(
              onPressed: auth.busy ? null : _submit,
              child: auth.busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            SocialSignInButton(
              label: 'Continue with Google',
              leading: SocialIcons.google,
              onPressed: auth.busy
                  ? null
                  : () => _run(context.read<AuthProvider>().signInWithGoogle),
            ),
            if (AppConfig.showAppleSignIn) ...[
              const SizedBox(height: 12),
              SocialSignInButton(
                label: 'Continue with Apple',
                leading: SocialIcons.apple,
                onPressed: auth.busy
                    ? null
                    : () => _run(context.read<AuthProvider>().signInWithApple),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: auth.busy
                      ? null
                      : () => Navigator.pushReplacementNamed(
                          context, AppRoutes.signup),
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
