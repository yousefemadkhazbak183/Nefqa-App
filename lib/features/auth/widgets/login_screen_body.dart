import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../../../core/theme/app_colors.dart';
import '../view_models/login_view_model.dart';

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Log in to continue tracking your expenses',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),

              ListenableBuilder(
                listenable: viewModel.loginCommand,
                builder: (context, _) {
                  if (viewModel.loginCommand.running) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      viewModel.loginCommand.execute((
                        email: _emailController.text,
                        password: _passwordController.text,
                      ));
                    },
                    child: const Text('Log in'),
                  );
                },
              ),

              ListenableBuilder(
                listenable: viewModel.loginCommand,
                builder: (context, _) {
                  if (viewModel.loginCommand.completed) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) context.go('/expenses');
                    });
                  }
                  if (viewModel.loginCommand.error) {
                    final result = viewModel.loginCommand.result as Failure;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        result.message,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/signup'),
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
