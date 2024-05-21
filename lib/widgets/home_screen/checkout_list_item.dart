import 'package:flutter/material.dart';

class CheckoutListItem extends StatelessWidget {
  const CheckoutListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container();
        });
  }
}
