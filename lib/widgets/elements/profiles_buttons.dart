import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final dynamic icon;
  final dynamic name;
  final dynamic action;
  const ProfileButton({Key? key, this.icon, this.name, this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      width: double.infinity,
      height: 65,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 25),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.onSurface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
            spreadRadius: 10,
            blurRadius: 45,
            offset: const Offset(0, 30), // changes position of shadow
          ),
        ],
      ),
      child: InkWell(
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onBackground),
            const SizedBox(width: 20),
            Text(
              name,
              style: Theme.of(context).textTheme.headline5?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.w700),
            )
          ],
        ),
        onTap: () {
          action;
        },
      ),
    );
  }
}
