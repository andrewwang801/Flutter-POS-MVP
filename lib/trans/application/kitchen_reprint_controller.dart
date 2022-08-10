import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../domain/trans_local_repository.dart';
import 'kitchen_state.dart';

@Injectable()
class KitchenReprintController extends StateNotifier<KitchenState> {
  KitchenReprintController(this.transRepository)
      : super(KitchenState(workable: Workable.initial));

  final TransLocalRepository transRepository;

  Future<void> fetchReprintData(
      int salesNo, int splitNo, String tableNo) async {
    state = KitchenState(workable: Workable.loading);
    try {
      final List<List<String>> reprintArray =
          await transRepository.reprintItem(salesNo, splitNo);

      state = KitchenState(
          workable: Workable.ready,
          kitchenData: KitchenData(reprintArray: reprintArray));
    } catch (_e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: _e.toString()));
    }
  }
}
