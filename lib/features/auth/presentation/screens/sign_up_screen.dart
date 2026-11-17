import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/helpers/extensions.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/validation/validated_text_field.dart';
import 'package:smart_memories/core/validation/validators.dart';
import 'package:smart_memories/core/widgets/app_button.dart';
import 'package:smart_memories/core/widgets/circle_icon_button.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().register(
      username: _username.text,
      email: _email.text,
      password: _password.text,
    );
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state case AuthFailure(:final error) when error.fieldErrors.isEmpty) {
          context.showSnack(error.message);
        }
      },
      builder: (context, state) {
        final error = switch (state) {
          AuthFailure(:final error) => error,
          _ => null,
        };

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.authPage,
                AppSpacing.x18,
                AppSpacing.authPage,
                AppSpacing.x24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleIconButton(
                        icon: Icons.chevron_left,
                        semanticLabel: 'Back to log in',
                        onPressed: _backToLogin,
                      ),
                    ),
                    AppGap.v24,
                    const Text(
                      'Start your archive',
                      style: AppTextStyles.displayLg,
                    ),
                    AppGap.v8,
                    const Text(
                      'Your memories stay private until you choose to share them.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    AppGap.v24,
                    ValidatedTextField(
                      label: 'Username',
                      controller: _username,
                      hint: 'sara.h',
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.newUsername],
                      serverError: error?.messageFor('username'),
                      validators: <Validator>[
                        Validators.required('Username'),
                        Validators.username(),
                      ],
                    ),
                    AppGap.v16,
                    ValidatedTextField(
                      label: 'Email',
                      controller: _email,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                      serverError: error?.messageFor('email'),
                      validators: <Validator>[
                        Validators.required('Email'),
                        Validators.email(),
                      ],
                    ),
                    AppGap.v16,
                    ValidatedTextField(
                      label: 'Password',
                      controller: _password,
                      hint: 'Choose a password',
                      helper: 'At least 10 characters. A long phrase works well.',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      serverError: error?.messageFor('password'),
                      validators: <Validator>[
                        Validators.required('Password'),
                        Validators.password(),
                      ],
                    ),
                    AppGap.v16,
                    ValidatedTextField(
                      label: 'Confirm password',
                      controller: _confirm,
                      hint: 'Type it again',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validators: <Validator>[
                        Validators.required('Confirm password'),
                        Validators.matches(
                          () => _password.text,
                          'The two passwords do not match.',
                        ),
                      ],
                    ),
                    AppGap.v24,
                    AppButton(
                      label: 'Create account',
                      isLoading: state is AuthLoading,
                      onPressed: _submit,
                    ),
                    AppGap.v24,
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Already have an account?',
                          style: AppTextStyles.bodySm,
                        ),
                        AppGap.h4,
                        AppButton(
                          label: 'Log in',
                          variant: AppButtonVariant.text,
                          size: AppButtonSize.pill,
                          expand: false,
                          onPressed: _backToLogin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
