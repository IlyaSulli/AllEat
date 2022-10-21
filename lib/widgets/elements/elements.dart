import 'package:flutter/material.dart';

class ScreenBackButton extends StatelessWidget {
  final dynamic data;
  const ScreenBackButton({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: TextButton.icon(
            onPressed: () => Navigator.of(context).pop(data),
            label: Text(
              "Back",
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            )));
  }
}