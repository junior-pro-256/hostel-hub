import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/routing/app_router.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_field.dart';
import '../widgets/social_sign_in_button.dart';

/// Create an account with email + password (or Google / Apple).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
    _run(() => context
        .read<AuthProvider>()
        .signUp(_name.text, _email.text, _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Join HostelHub in a minute',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: AuthProvider.validateName,
              decoration: const InputDecoration(
                  labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AuthProvider.validateEmail,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              validator: AuthProvider.validatePassword,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: 'Confirm password',
              validator: (v) =>
                  v == _password.text ? null : 'Passwords do not match',
              onSubmitted: _submit,
            ),
            const SizedBox(height: 16),
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
                  : const Text('Create account'),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or sign up with',
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
                const Text('Already have an account?'),
                TextButton(
                  onPressed: auth.busy
                      ? null
                      : () => Navigator.pushReplacementNamed(
                          context, AppRoutes.login),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
