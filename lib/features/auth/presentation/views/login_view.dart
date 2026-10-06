import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exquisssita_manager/app/theme/exquisssita_tokens.dart';
import 'package:exquisssita_manager/shared/widgets/exquisssita_components.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';

/// Pantalla de inicio de sesión.
///
/// Soporta modo claro y oscuro. El layout se adapta a dispositivos móviles.
/// Las credenciales son validadas por el ViewModel antes de enviarse.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (ref.read(authViewModelProvider).isLoading ||
        !_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(authViewModelProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final t = context.exq;
    final m = t.metrics;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(m.spaceXxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.contentMax),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: m.logo,
                      height: m.logo,
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(m.radiusCard),
                        boxShadow: t.cardShadow,
                      ),
                      child: Icon(
                        Icons.restaurant_outlined,
                        color: t.onAccent,
                        size: m.iconLarge,
                      ),
                    ),
                  ),
                  SizedBox(height: m.spaceL),
                  Semantics(
                    header: true,
                    child: Text('Exquisssita', style: t.text.displayLarge),
                  ),
                  SizedBox(height: m.spaceXs),
                  Text('Sistema administrativo', style: t.body),
                  SizedBox(height: m.section),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ExquisssitaFormField(
                          key: const Key('login_email_field'),
                          label: 'Correo electrónico',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !state.isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo electrónico';
                            }
                            return value.contains('@')
                                ? null
                                : 'Correo electrónico inválido';
                          },
                        ),
                        SizedBox(height: m.spaceL),
                        ExquisssitaFormField(
                          key: const Key('login_password_field'),
                          label: 'Contraseña',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !state.isLoading,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onLogin(),
                          suffix: ExquisssitaIconAction(
                            label: _obscurePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onPressed: state.isLoading
                                ? null
                                : () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return value.length < 6
                                ? 'La contraseña debe tener al menos 6 caracteres'
                                : null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (state.hasError) ...[
                    SizedBox(height: m.spaceM),
                    ExquisssitaErrorState(message: state.failure!.message),
                  ],
                  SizedBox(height: m.spaceXl),
                  ExquisssitaAction(
                    key: const Key('login_button'),
                    label: 'Iniciar sesión',
                    onPressed: _onLogin,
                    busy: state.isLoading,
                  ),
                  SizedBox(height: m.section),
                  Text(
                    'Solo personal autorizado',
                    style: t.caption,
                    textAlign: TextAlign.center,
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
