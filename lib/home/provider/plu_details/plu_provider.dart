import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/home/provider/plu_details/plu_state.dart';
import 'package:raptorpos/home/provider/plu_details/plu_state_notifier.dart';

final pluProvider = StateNotifierProvider<PLUStateNotifier, PLUState>(((ref) {
  return GetIt.I<PLUStateNotifier>();
}));
