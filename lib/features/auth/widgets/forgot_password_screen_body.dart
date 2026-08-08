import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../view_models/forget_password_view_model.dart';

class ForgotPasswordScreenBody extends StatefulWidget {
  const ForgotPasswordScreenBody({super.key});

  @override
  State<ForgotPasswordScreenBody> createState() =>
      _ForgotPasswordScreenBodyState();
}

class _ForgotPasswordScreenBodyState extends State<ForgotPasswordScreenBody> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: viewModel.resetPasswordCommand,
              builder: (context, _) {
                if (viewModel.resetPasswordCommand.running) {
                  return const CircularProgressIndicator();
                }

                if (viewModel.resetPasswordCommand.completed) {
                  return const Text(
                    'Check your email for reset instructions.',
                    style: TextStyle(color: Colors.green),
                  );
                }

                return ElevatedButton(
                  onPressed: () {
                    viewModel.resetPasswordCommand.execute(
                      _emailController.text,
                    );
                  },
                  child: const Text('Send Reset Email'),
                );
              },
            ),

            ListenableBuilder(
              listenable: viewModel.resetPasswordCommand,
              builder: (context, _) {
                if (viewModel.resetPasswordCommand.error) {
                  final result =
                      viewModel.resetPasswordCommand.result as Failure;
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
          ],
        ),
      ),
    );
  }
}
