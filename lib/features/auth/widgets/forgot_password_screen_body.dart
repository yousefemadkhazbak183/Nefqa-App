import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reset password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "We'll send you a link to reset your password",
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
            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: viewModel.resetPasswordCommand,
              builder: (context, _) {
                if (viewModel.resetPasswordCommand.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.resetPasswordCommand.completed) {
                  return Text(
                    'Check your email for reset instructions.',
                    style: TextStyle(color: AppColors.categoryTeal),
                  );
                }
                return ElevatedButton(
                  onPressed: () {
                    viewModel.resetPasswordCommand.execute(
                      _emailController.text,
                    );
                  },
                  child: const Text('Send reset email'),
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
