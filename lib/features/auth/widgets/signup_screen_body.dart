import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: viewModel.signUpCommand,
              builder: (context, _) {
                if (viewModel.signUpCommand.running) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  onPressed: () {
                    viewModel.signUpCommand.execute((
                      email: _emailController.text,
                      password: _passwordController.text,
                      name: _nameController.text,
                    ));
                  },
                  child: const Text('Sign Up'),
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
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text("Already have an account? Login#"),
            ),
          ],
        ),
      ),
    );
  }
}
