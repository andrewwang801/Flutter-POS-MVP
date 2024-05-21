import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/custom_button.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/home/model/prep/prep_model.dart';
import 'package:raptorpos/home/presentation/widgets/prep_item_card.dart';
import 'package:raptorpos/common/extension/string_extension.dart';

typedef PreListCallback = Function(Map<String, Map<String, String>> prepSelect);

class PreListWidget extends ConsumerStatefulWidget {
  final List<PrepModel> preps;
  final Map<String, Map<String, String>> prepSelect;
  final PreListCallback callback;
  PreListWidget(this.preps, this.prepSelect, this.callback, {Key? key})
      : super(key: key);

  @override
  _PreListWidgetState createState() => _PreListWidgetState();
}

class _PreListWidgetState extends ConsumerState<PreListWidget> {
  Map<String, Map<String, String>> _prepSlect = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        heightFactor: 0.6,
        child: Container(
            color: backgroundDarkColor,
            padding: EdgeInsets.all(10.h),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                      itemCount: widget.preps.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.h,
                        mainAxisExtent: 80.h,
                        mainAxisSpacing: 10.h,
                      ),
                      itemBuilder: (context, index) {
                        PrepModel prep = widget.preps[index];
                        if (widget.prepSelect.containsKey(prep.number)) {
                          prep.quantity = widget.prepSelect[prep.number]
                                      ?['Quantity']
                                  ?.toInt() ??
                              0;
                        }
                        return PrepItemCard(prep, prepItemHandler);
                      }),
                ),
                CustomButton(
                    callback: () {
                      for (var prep in widget.preps) {
                        if (prep.quantity! > 0) {
                          _prepSlect[prep.number!] = {
                            'PLUName': prep.name!,
                            'Quantity': prep.quantity!.toString()
                          };
                        }
                      }
                      widget.callback(_prepSlect);
                      Get.back();
                    },
                    text: 'Done',
                    borderColor: Colors.transparent,
                    fillColor: primaryDarkColor)
              ],
            )),
      ),
    );
  }

  prepItemHandler(PrepModel prep) {}
}
