import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const MainAppBar({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: SafeArea(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).textTheme.headline1?.color,
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Location",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    "54 Main Street",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(fontWeight: FontWeight.w600),
                  )
                ]),
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).textTheme.headline1?.color,
                ),
              ]),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
