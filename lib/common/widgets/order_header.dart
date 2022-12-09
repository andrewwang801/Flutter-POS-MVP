import 'package:flutter/material.dart';
import 'package:raptorpos/constants/color_constant.dart';

class OrderHeader extends StatelessWidget {
  const OrderHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColorVariant),
      child: ListTile(
        dense: true,
        title: Text('Sales Category'),
        subtitle: Text('Dine In'),
        trailing: IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.edit,
              color: blue,
            )),
      ),
    );
  }
}
