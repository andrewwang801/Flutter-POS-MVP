import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/sales_category/model/sales_category_model.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

class OrderHeader extends ConsumerStatefulWidget {
  OrderHeader({Key? key}) : super(key: key);

  @override
  _OrderHeaderState createState() => _OrderHeaderState();
}

class _OrderHeaderState extends ConsumerState<OrderHeader> {
  late bool isDark;

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    SalesCategoryModel salesCategory =
        GlobalConfig.salesCategoryList.firstWhere((element) {
      return element.id == POSDtls.categoryID;
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: ListTile(
        tileColor: isDark
            ? Responsive.isMobile(context)
                ? primaryDarkColor
                : backgroundDarkColor
            : backgroundColorVariant,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.sm)),
        dense: true,
        title: Text('Sales Category'),
        subtitle: Text(salesCategory.name ?? ''),
        trailing: IconButton(
            onPressed: () {
              // setState(() {
              //   if (POSDtls.categoryID == 1) {
              //     POSDtls.categoryID = 3;
              //   } else if (POSDtls.categoryID == 3) {
              //     POSDtls.categoryID = 1;
              //   }
              // });

              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Spacing.md),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter setModalState) {
                      return ListView.separated(
                          padding: EdgeInsets.all(Spacing.sm),
                          itemCount: GlobalConfig.salesCategoryList.length + 1,
                          separatorBuilder: (BuildContext context, int index) {
                            if (index != 0) {
                              return Divider();
                            }
                            return Container();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  verticalSpaceRegular,
                                  Text(
                                    'Sales Category',
                                    style: isDark
                                        ? titleTextDarkStyle
                                        : titleTextLightStyle,
                                  ),
                                  verticalSpaceRegular,
                                ],
                              );
                            } else {
                              SalesCategoryModel salesCategory =
                                  GlobalConfig.salesCategoryList[index - 1];
                              bool isChecked =
                                  POSDtls.categoryID == salesCategory.id;
                              String strBtnText =
                                  isChecked ? 'Selected' : 'Select';

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(salesCategory.name ?? ''),
                                  _checkBoxButton(isDark, isChecked, strBtnText,
                                      (bool value) {
                                    if (value) {
                                      setModalState(() {
                                        POSDtls.categoryID = salesCategory.id;
                                      });
                                      setState(() {
                                        POSDtls.categoryID = salesCategory.id;
                                      });
                                    }
                                  }),
                                ],
                              );
                            }
                          });
                    });
                  });
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.edit,
              color: blue,
            )),
      ),
    );
  }

  Widget _checkBoxButton(
      bool isDark, bool isChecked, String text, Function callback) {
    return GestureDetector(
      onTap: () {
        callback(true);
      },
      child: Container(
          // height: 16.h,
          padding: EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: isChecked ? lightGreen : orange,
            borderRadius: BorderRadius.circular(Spacing.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontalSpaceSmall,
              if (isChecked)
                SizedBox(
                  width: mdiconsize,
                  height: mdiconsize,
                  child: Checkbox(
                    value: isChecked,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (bool? newValue) {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    checkColor: greenVariant2,
                    activeColor: greenVariant2.withOpacity(0.5),
                  ),
                ),
              if (isChecked) horizontalSpaceSmall,
              Text(
                text,
                textAlign: TextAlign.center,
                style: isDark
                    ? bodyTextDarkStyle.copyWith(
                        color: isChecked ? greenVariant2 : Colors.black)
                    : bodyTextLightStyle.copyWith(
                        color: isChecked ? greenVariant2 : Colors.white),
              ),
              horizontalSpaceSmall,
            ],
          )),
    );
  }

  String categoryType() {
    if (POSDtls.categoryID == 1) {
      return 'Take Away';
    } else if (POSDtls.categoryID == 3) {
      return 'DINE IN';
    } else {
      return 'Delivery';
    }
  }
}
