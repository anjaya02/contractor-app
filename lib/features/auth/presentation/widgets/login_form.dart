import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../view_models/login_view_model.dart';
import '../view_models/login_state.dart';
import '../sid_validator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _sidController = TextEditingController();

  @override
  void dispose() {
    _sidController.dispose();
    super.dispose();
  }

  void _submit() {
    final model = context.read<LoginViewModel>();
    if (model.state.isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    model.signIn(_sidController.text);
  }

  void _showHelp() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help with signing in',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Use the service ID assigned to you, including any leading zeroes. '
                'If you do not have an ID or cannot sign in, contact your SLT administrator.',
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Selector<LoginViewModel, LoginState>(
      selector: (_, model) => model.state,
      builder: (context, state, _) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ACCOUNT ACCESS',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 12),
            Text('Welcome back.', style: textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter your service ID to sign in.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              key: const ValueKey('sidField'),
              controller: _sidController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autocorrect: false,
              enableSuggestions: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: validateSid,
              onChanged: (_) => context.read<LoginViewModel>().clearError(),
              onFieldSubmitted: (_) => _submit(),
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              decoration: const InputDecoration(
                labelText: 'Service ID (SID)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Enter your service ID',
                prefixIcon: Icon(Icons.badge_outlined, size: 21),
                helperText: 'Use the ID assigned by your administrator.',
                helperMaxLines: 3,
                errorMaxLines: 3,
              ),
            ),
            if (state.error case final error?) ...[
              const SizedBox(height: AppSpacing.md),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          error,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isSubmitting) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(state.isSubmitting ? 'Signing in…' : 'Sign in'),
                  ),
                  if (!state.isSubmitting) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: state.isSubmitting ? null : _showHelp,
                style: TextButton.styleFrom(foregroundColor: AppColors.teal),
                child: const Text('Need help signing in?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
