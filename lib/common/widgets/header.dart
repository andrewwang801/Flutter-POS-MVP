import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String transID;
  final String operator;
  final String mode;
  final String order;
  final String cover;
  final String rcp;
  const Header(
      {Key? key,
      required this.transID,
      required this.operator,
      required this.mode,
      required this.order,
      required this.cover,
      required this.rcp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
          '$transID Operator: $operator Mode: $mode Order: $order Cover: $cover Rcp: $rcp  ${DateTime.now()}'),
    );
  }
}
