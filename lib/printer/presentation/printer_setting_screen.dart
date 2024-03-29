import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/print/provider/print_provider.dart';
import 'package:raptorpos/print/provider/print_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/services/printer_manager.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/responsive.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../model/printer_model.dart';
import '../provider/printer_provider.dart';
import '../provider/printer_state.dart';
import '../widgets/printer_add_widget.dart';
import '../widgets/printer_update_widget.dart';
import 'widget/empty_printers_widget.dart';

class PrinterSettingScreen extends ConsumerStatefulWidget {
  PrinterSettingScreen({Key? key}) : super(key: key);

  @override
  _PrinterSettingScreenState createState() => _PrinterSettingScreenState();
}

class _PrinterSettingScreenState extends ConsumerState<PrinterSettingScreen> {
  int? selectedPrinter;
  List<PrinterModel> printers = <PrinterModel>[];
  int printerID = 0;

  late bool isDark;
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(printerProvider.notifier).fetchPrinters();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(printProvider, (previous, next) {
      if (next is PrintSuccessState) {
      } else if (next is PrintErrorState) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });
    ref.listen(
      printerProvider,
      (previous, next) {
        ProgressHUD.of(context)?.dismiss();
        if (next is PrinterSuccessState) {
          printers = next.printers;
          if (printers.isNotEmpty) {
            printerID = next.printers[next.printers.length - 1].printerID + 1;
          }
          if (next.operation == OPERATION.CONNECT_SUCCESS) {
            showDialog(
                context: context,
                builder: (context) {
                  return AppAlertDialog(
                    title: 'Printer',
                    isDark: isDark,
                    message: 'Printer connected',
                    onConfirm: () {},
                  );
                });
          } else if (next.operation == OPERATION.CONNECT_FAIL) {
            showDialog(
                context: context,
                builder: (context) {
                  return AppAlertDialog(
                    title: 'Printer',
                    isDark: isDark,
                    message: next.message,
                    onConfirm: () {},
                  );
                });
          } else if (next.operation == OPERATION.DISCONNECT_SUCCESS) {
            showDialog(
                context: context,
                builder: (context) {
                  return AppAlertDialog(
                    title: 'Printer',
                    isDark: isDark,
                    message: 'Printer Disconnected',
                    onConfirm: () {},
                  );
                });
          }
        }
        if (next is PrinterErrorState) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Error',
                  isDark: isDark,
                  message: next.errMsg,
                  onConfirm: () {},
                );
              });
        }
      },
    );
    isDark = ref.watch(themeProvider);

    ref.watch(printerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? backgroundColor : primaryDarkColor,
          ),
        ),
        title: Text(
          'Printer',
          style: isDark ? normalTextDarkStyle : normalTextLightStyle,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (printers.isNotEmpty) _header(),
            Expanded(child: _printerListView()),
            _bottomBtnGroup(),
          ],
        ),
      ),
    );
  }

  Widget _bottomBtnGroup() {
    return Padding(
      padding: EdgeInsets.all(10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CustomButton(
                height: Responsive.isMobile(context) ? 35.h : 25.h,
                callback: () {
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return Dialog(
                            child: IntrinsicWidth(
                          child: IntrinsicHeight(
                            child: PrinterAddWidget(
                              isDark: isDark,
                              printerID: printerID,
                            ),
                          ),
                        ));
                      });
                },
                text: 'ADD',
                borderColor: isDark ? orange : orange,
                fillColor: isDark ? orange : orange),
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: CustomButton(
                height: Responsive.isMobile(context) ? 35.h : 25.h,
                callback: () {
                  if (selectedPrinter == null) return;
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return Dialog(
                            child: IntrinsicWidth(
                          child: IntrinsicHeight(
                            child: PrinterUpdateWidget(
                              isDark: isDark,
                              printer: printers[selectedPrinter!],
                            ),
                          ),
                        ));
                      });
                },
                text: 'UPDATE',
                borderColor: isDark ? orange : orange,
                fillColor: isDark ? orange : orange),
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: CustomButton(
                height: Responsive.isMobile(context) ? 35.h : 25.h,
                callback: () {
                  if (selectedPrinter != null) {
                    deletePrinter(printers[selectedPrinter!].printerID);
                  }
                },
                text: 'DELETE',
                borderColor: isDark ? orange : orange,
                fillColor: isDark ? orange : orange),
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: CustomButton(
                height: Responsive.isMobile(context) ? 35.h : 25.h,
                callback: () {
                  Get.back();
                },
                text: 'CLOSE',
                borderColor: isDark ? orange : orange,
                fillColor: isDark ? orange : orange),
          ),
        ],
      ),
    );
  }

  Widget _printerListView() {
    PrinterState state = ref.read(printerProvider.notifier).state;

    if (state is PrinterSuccessState) {
      if (printers.isEmpty) {
        return EmptyPrintersWidget(
          message: 'There are no printers connected. Please add printers.',
          icon: Icons.print_rounded,
          isDark: isDark,
        );
      }
      return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: printers.length,
          itemBuilder: (BuildContext context, int index) {
            return _printerListItem(printers[index], index);
          });
    } else if (state is PrinterLoadingState) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _printerListItem(PrinterModel printer, int index) {
    bool isConnected =
        GetIt.I<PrinterManager>().isConnected(printers[index].address);
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPrinter = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: index.isOdd
              ? (isDark ? backgroundDarkColor : backgroundColor)
              : (isDark
                  ? secondaryBackgroundDarkColor
                  : backgroundColorVariant),
          border: (selectedPrinter != null && selectedPrinter == index)
              ? Border.all(width: 1.0, color: backgroundColor)
              : Border.all(width: 0, color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  printer.printerID.toString(),
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.printerDeviceName,
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.printerType,
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.interfaceType.toString(),
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.address,
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.port.toString(),
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                )),
            CustomButton(
              text: isConnected ? 'Disconnect' : 'Connect',
              callback: () async {
                final progress = ProgressHUD.of(context);
                progress?.show();
                if (!isConnected) {
                  await createPrinter(printer);
                } else {
                  await disconnectPrinter(printer);
                }
              },
              borderColor: Colors.amber,
              fillColor: Colors.amber,
              height: Responsive.isMobile(context) ? 35.h : 25.h,
              width: 100.w,
            )
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Text(
        'Printers',
        textAlign: TextAlign.center,
        style: isDark ? titleTextDarkStyle : titleTextLightStyle,
      ),
    );
  }

  Future<void> deletePrinter(int id) async {
    await ref.read(printerProvider.notifier).deletePrinter(id);
  }

  Future<void> createPrinter(PrinterModel printer) async {
    await ref.read(printerProvider.notifier).connectPrinter(printer);
  }

  Future<void> disconnectPrinter(PrinterModel printer) async {
    await ref.read(printerProvider.notifier).disconnectPrinter(printer);
  }
}
