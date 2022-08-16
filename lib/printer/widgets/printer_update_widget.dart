import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/printer/model/printer_model.dart';

import '../../common/extension/string_extension.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/custom_button.dart';
import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../provider/printer_provider.dart';
import '../provider/printer_state.dart';

class PrinterUpdateWidget extends ConsumerWidget {
  PrinterUpdateWidget({required this.printer, Key? key}) : super(key: key) {
    printerName = printer.printerDeviceName;
    printerAddress = printer.address;
    printerPort = printer.port.toString();
    printerModel = printer.printerType;
  }

  final PrinterModel printer;

  String printerName = '';
  String printerAddress = '';
  String printerPort = '';
  String? printerModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      printerProvider,
      (previous, next) {
        if (next is PrinterSuccessState) {
          Get.back();
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Success',
                  message: 'Printer Updated!',
                  onConfirm: () {},
                );
              });
        } else if (next is PrinterErrorState) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Error',
                  message: next.errMsg,
                );
              });
        }
      },
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          header(),
          SizedBox(
            height: 10.h,
          ),
          printerNameRow(),
          SizedBox(
            height: 10.h,
          ),
          printerTypeRow(ref),
          SizedBox(
            height: 10.h,
          ),
          printerAddrRow(),
          SizedBox(
            height: 10.h,
          ),
          printerPortRow(),
          SizedBox(
            height: 20.h,
          ),
          btnGroup(ref),
        ],
      ),
    );
  }

  Widget header() {
    return Center(
      child: Text(
        'Add Printer',
        style: titleTextDarkStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget btnGroup(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
            callback: () async {
              PrinterModel _printer = PrinterModel(
                  printerID: printer.printerID,
                  printerType: printerModel ?? '',
                  printerDeviceName: printerName,
                  address: printerAddress,
                  port: printerPort.toInt(),
                  interfaceType: 2);
              await updatePrinter(ref, _printer);
            },
            text: 'UPDATE',
            borderColor: primaryDarkColor,
            fillColor: primaryDarkColor),
        SizedBox(
          width: 20.w,
        ),
        CustomButton(
            callback: () {
              Get.back();
            },
            text: 'CANCEL',
            borderColor: primaryDarkColor,
            fillColor: primaryDarkColor)
      ],
    );
  }

  Widget interfaceRow(List<DropdownMenuItem<String>> items) {
    return Row(
      children: [
        Expanded(flex: 1, child: Text('InterfaceType')),
        Expanded(
            flex: 3,
            child: DropdownButton(items: items, onChanged: (String? item) {})),
      ],
    );
  }

  Widget printerTypeRow(WidgetRef ref) {
    List<DropdownMenuItem<String>>? items;
    PrinterState state = ref.read(printerProvider.notifier).state;
    if (state is PrinterSuccessState) {
      items = state.printerSupportList
          .map((e) => DropdownMenuItem<String>(
              value: e.printerModel, child: Text(e.printerModel)))
          .toList();
    }

    return Row(
      children: [
        Expanded(flex: 1, child: Text('Printer Model')),
        Spacer(),
        Expanded(
            flex: 3,
            child: DropdownButton(
              value: printerModel,
              items: items,
              onChanged: (String? item) {},
            )),
      ],
    );
  }

  Widget printerNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(flex: 1, child: Text('Printer Name')),
        Spacer(),
        Expanded(
          flex: 3,
          child: TextFormField(
            onChanged: (String value) {
              printerName = value;
            },
            initialValue: printerName,
            decoration: const InputDecoration(
              hintText: 'Printer Name',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget printerAddrRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(flex: 1, child: Text('Address')),
        Spacer(),
        Expanded(
          flex: 3,
          child: TextFormField(
            onChanged: (String value) {
              printerAddress = value;
            },
            initialValue: printerAddress,
            decoration: const InputDecoration(
              hintText: 'Printer Address',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget printerPortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(flex: 1, child: Text('Port')),
        Spacer(),
        Expanded(
          flex: 3,
          child: TextFormField(
            onChanged: (String value) {
              printerPort = value;
            },
            initialValue: printerPort,
            decoration: const InputDecoration(
              hintText: 'Port',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> addPrinter(WidgetRef ref, PrinterModel printer) async {
    await ref.read(printerProvider.notifier).addPrinter(printer);
  }

  Future<void> updatePrinter(WidgetRef ref, PrinterModel printer) async {
    await ref.read(printerProvider.notifier).updatePrinter(printer);
  }
}
