
import 'package:flutter/material.dart';

class RowItem extends StatelessWidget {
  final text;
  final value;

  RowItem(this.text, this.value);
//  Row for device info
  Widget customRow(){
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Text(text,
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.white70)),
        ),
        Spacer(flex: 4),
        Expanded(
            flex: 5,
            child: Text(value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                )))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Padding(padding: EdgeInsets.fromLTRB(25.0, 5.0, 15.0, 0.0),
        child: customRow(),
      )
    );
  }
}
