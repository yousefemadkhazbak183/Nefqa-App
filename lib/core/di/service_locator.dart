import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../features/auth/view_models/forget_password_view_model.dart';
import '../../features/auth/view_models/login_view_model.dart';
import '../../features/auth/view_models/signup_view_model.dart';

final getIt = GetIt.instance;

void setupServerLocator(){
  // Supabase Client Singleton
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Auth Repository Singleton
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(getIt<SupabaseClient>()),
  );

  // ViewModel factory
  getIt.registerFactory<LoginViewModel>(
        () => LoginViewModel(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignupViewModel>(
        () => SignupViewModel(getIt<AuthRepository>()),
  );

  getIt.registerFactory<ForgotPasswordViewModel>(
        () => ForgotPasswordViewModel(getIt<AuthRepository>()),
  );
}