import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/home/model/prep/prep_model.dart';
import 'package:raptorpos/home/provider/plu_details/plu_state.dart';
import 'package:raptorpos/home/repository/menu/i_menu_repository.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';

@Injectable()
class PLUStateNotifier extends StateNotifier<PLUState> {
  final IMenuRepository menuRepository;
  final IOrderRepository orderRepository;

  PLUStateNotifier(this.menuRepository, this.orderRepository)
      : super(PLUInitialState());

  void fetchMenuDetail(String pluNo, int salesRef) async {
    try {
      Map<String, Map<String, String>> prepSelect =
          <String, Map<String, String>>{};
      final pluDetails = await menuRepository.getPLUDetails(pluNo);
      final orderSelect = await orderRepository.getOrderSelectData(salesRef);
      final modSelect = await orderRepository.getModSelectData(salesRef);
      final prepOrderItems = await orderRepository.getPrepSelectData(salesRef);

      for (var orderItem in prepOrderItems) {
        String prepPluNo = orderItem.PLUNo ?? "";
        int prepQty = orderItem.Quantity ?? 0;
        String prepName = orderItem.ItemName ?? "";

        Map<String, String> tempPrep = <String, String>{};
        tempPrep['PLUName'] = prepName;
        tempPrep['Quantity'] = prepQty.toString();
        prepSelect[prepPluNo] = tempPrep;
      }

      List<PrepModel> preps = [];
      if (pluDetails.length > 7) {
        int linkMenuNo = pluDetails[7].toInt();
        preps = await menuRepository.getPrepData(linkMenuNo);
      }

      state = PLUSuccessState(prepSelect, pluDetails, orderSelect, modSelect,
          prepOrderItems, preps);
    } catch (e) {
      state = PLUErrorState(e.toString());
    }
  }
}
