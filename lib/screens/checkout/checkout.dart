import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';

class Checkout extends StatefulWidget {
  final List cartInfo;
  const Checkout({Key? key, required this.cartInfo}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScreenBackButton(),
      Text(
        "Checkout",
        style: Theme.of(context).textTheme.headline1,
      ),
      SizedBox(
        height: 30,
      ),
      Text(widget.cartInfo.toString())
    ])));
  }
}
