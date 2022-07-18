import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/model/prep/prep_model.dart';

typedef Callback = Function(PrepModel prep);

class PrepItemCard extends ConsumerStatefulWidget {
  const PrepItemCard(this.prep, this.callback, {Key? key}) : super(key: key);
  final PrepModel prep;
  final Callback callback;

  @override
  _PrepItemCardState createState() => _PrepItemCardState();
}

class _PrepItemCardState extends ConsumerState<PrepItemCard> {
  late bool _isChecked;
  late PrepModel _prepModel;
  @override
  void initState() {
    _prepModel = widget.prep;
    if (_prepModel.quantity! > 0) {
      _isChecked = true;
    } else {
      _isChecked = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              // widget.callback(_prepModel);
            },
            child: Stack(
              children: [
                Material(
                  color: primaryDarkColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0)),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                        if (_isChecked)
                          _prepModel.quantity = 1;
                        else
                          _prepModel.quantity = 0;
                      });
                    },
                    child: Center(child: Text(_prepModel.name ?? '')),
                  ),
                ),
                if (_isChecked)
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _prepModel.quantity = _prepModel.quantity! - 1;
                  if (_prepModel.quantity! <= 0) _isChecked = false;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 25,
                      height: 25,
                    ),
                  ),
                  Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  )
                ],
              ),
            ),
            Container(
              child: DefaultTextStyle(
                style: bodyTextDarkStyle,
                child: Text(
                  "${_prepModel.quantity}",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _prepModel.quantity = _prepModel.quantity! + 1;
                  if (_prepModel.quantity! > 0) _isChecked = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 25,
                      height: 25,
                    ),
                  ),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
