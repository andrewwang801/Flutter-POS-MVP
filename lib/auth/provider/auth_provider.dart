import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'auth_controller.dart';

import 'auth_state.dart';

final StateNotifierProvider<AuthController, AuthState> authProvider =
    StateNotifierProvider<AuthController, AuthState>(
        (StateNotifierProviderRef<AuthController, AuthState> ref) {
  return GetIt.I<AuthController>();
});
