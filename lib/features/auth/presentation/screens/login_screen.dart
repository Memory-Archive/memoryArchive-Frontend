import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/helpers/extensions.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/validation/validated_text_field.dart';
import 'package:smart_memories/core/validation/validators.dart';
import 'package:smart_memories/core/widgets/app_button.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_state.dart';
import 'package:smart_memories/features/auth/presentation/widgets/polaroid_stack.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().login(
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Errors tied to a field are shown under that field instead.
        if (state case AuthFailure(:final error) when error.fieldErrors.isEmpty) {
          context.showSnack(error.message);
        }
        // Success needs no handling: the router sees the new session.
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
                AppSpacing.x28,
                AppSpacing.authPage,
                AppSpacing.x24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const PolaroidStack(),
                    AppGap.v28,
                    const Text(
                      AppStrings.appName,
                      style: AppTextStyles.displayXl,
                    ),
                    AppGap.v8,
                    const Text(
                      'Every place you have been, kept in one private album.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    AppGap.v28,
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
                      hint: 'Your password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.password],
                      serverError: error?.messageFor('password'),
                      onFieldSubmitted: (_) => _submit(),
                      validators: <Validator>[Validators.required('Password')],
                    ),
                    AppGap.v8,
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        label: 'Forgot password?',
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.pill,
                        expand: false,
                        onPressed: () =>
                            context.showSnack(AppStrings.notAvailableYet),
                      ),
                    ),
                    AppGap.v8,
                    AppButton(
                      label: 'Log in',
                      isLoading: state is AuthLoading,
                      onPressed: _submit,
                    ),
                    AppGap.v28,
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        const Text('New here?', style: AppTextStyles.bodySm),
                        AppGap.h4,
                        AppButton(
                          label: 'Create an account',
                          variant: AppButtonVariant.text,
                          size: AppButtonSize.pill,
                          expand: false,
                          onPressed: () => context.push(AppRoutes.signUp),
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
