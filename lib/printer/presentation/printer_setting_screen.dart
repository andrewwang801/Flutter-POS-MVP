import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/print/provider/print_provider.dart';
import 'package:raptorpos/print/provider/print_state.dart';

import '../../common/services/iprinter_service.dart';
import '../../common/services/printer_manager.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/custom_button.dart';
import '../../constants/color_constant.dart';
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
                    message: 'Printer connection failed',
                    onConfirm: () {},
                  );
                });
          } else if (next.operation == OPERATION.DISCONNECT_SUCCESS) {
            showDialog(
                context: context,
                builder: (context) {
                  return AppAlertDialog(
                    title: 'Printer',
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
                  message: next.errMsg,
                  onConfirm: () {},
                );
              });
        }
      },
    );

    ref.watch(printerProvider);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBarWidget(false),
          if (printers.isNotEmpty) _header(),
          Expanded(child: _printerListView()),
          _bottomBtnGroup(),
        ],
      ),
    );
  }

  Widget _bottomBtnGroup() {
    return Padding(
      padding: EdgeInsets.all(10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButton(
              height: 25.h,
              width: 120.w,
              callback: () {
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return Dialog(
                          child: IntrinsicWidth(
                        child: IntrinsicHeight(
                          child: PrinterAddWidget(
                            printerID: printerID,
                          ),
                        ),
                      ));
                    });
              },
              text: 'ADD',
              borderColor: primaryDarkColor,
              fillColor: primaryDarkColor),
          SizedBox(
            width: 15.w,
          ),
          CustomButton(
              height: 25.h,
              width: 120.w,
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
                            printer: printers[selectedPrinter!],
                          ),
                        ),
                      ));
                    });
              },
              text: 'UPDATE',
              borderColor: primaryDarkColor,
              fillColor: primaryDarkColor),
          SizedBox(
            width: 15.w,
          ),
          CustomButton(
              height: 25.h,
              width: 120.w,
              callback: () {
                if (selectedPrinter != null) {
                  deletePrinter(printers[selectedPrinter!].printerID);
                }
              },
              text: 'DELETE',
              borderColor: primaryDarkColor,
              fillColor: primaryDarkColor),
          SizedBox(
            width: 15.w,
          ),
          CustomButton(
              height: 25.h,
              width: 120.w,
              callback: () {
                Get.back();
              },
              text: 'CLOSE',
              borderColor: primaryDarkColor,
              fillColor: primaryDarkColor),
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
          color: index.isOdd ? backgroundDarkColor : primaryDarkColor,
          border: (selectedPrinter != null && selectedPrinter == index)
              ? Border.all(width: 1.0, color: Colors.green)
              : Border.all(width: 0, color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  printer.printerID.toString(),
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.printerDeviceName,
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.printerType,
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.interfaceType.toString(),
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.address,
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  printer.port.toString(),
                  textAlign: TextAlign.center,
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
              height: 20.h,
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
        style: titleTextDarkStyle,
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
