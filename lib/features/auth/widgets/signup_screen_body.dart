import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../../../core/theme/app_colors.dart';
import '../view_models/signup_view_model.dart';

class SignupScreenBody extends StatefulWidget {
  const SignupScreenBody({super.key});

  @override
  State<SignupScreenBody> createState() => _SignupScreenBodyState();
}

class _SignupScreenBodyState extends State<SignupScreenBody> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignupViewModel>();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start tracking your expenses with Nafqa',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _nameController,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 14),
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
              listenable: viewModel.signUpCommand,
              builder: (context, _) {
                if (viewModel.signUpCommand.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: () {
                    viewModel.signUpCommand.execute((
                      email: _emailController.text,
                      password: _passwordController.text,
                      name: _nameController.text,
                    ));
                  },
                  child: const Text('Sign up'),
                );
              },
            ),

            ListenableBuilder(
              listenable: viewModel.signUpCommand,
              builder: (context, _) {
                if (viewModel.signUpCommand.error) {
                  final result = viewModel.signUpCommand.result as Failure;
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
          ],
        ),
      ),
    );
  }
}
