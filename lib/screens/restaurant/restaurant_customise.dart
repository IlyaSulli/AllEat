import 'package:flutter/material.dart';

class RestaurantItemCustomisePage extends StatefulWidget {
  final String itemid;
  final String foodcategory;
  final String subfoodcategory;
  final String itemname;
  final String description;
  final String price;
  final String itemimage;
  final String reslogo;
  const RestaurantItemCustomisePage(
      {Key?
          key, //Get the items from the restaurant main page when an item is clicked
      required this.reslogo,
      required this.itemid,
      required this.foodcategory,
      required this.subfoodcategory,
      required this.itemname,
      required this.description,
      required this.price,
      required this.itemimage})
      : super(key: key);

  @override
  State<RestaurantItemCustomisePage> createState() =>
      _RestaurantItemCustomisePageState();
}

class _RestaurantItemCustomisePageState
    extends State<RestaurantItemCustomisePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 240,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: NetworkImage(widget.itemimage),
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 215),
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20))),
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: const EdgeInsets.only(top: 180),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).backgroundColor,
                  ))),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: const EdgeInsets.only(top: 185),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.reslogo.toString()),
                    ),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ))),
          SafeArea(
              child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, left: 20),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).colorScheme.onBackground,
                      size: 35,
                    ),
                  ))),
        ]),
        Padding(
            padding:
                const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 10),
            child: Text(
              widget.itemname,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline2,
            )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.foodcategory, //Must have food category
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Theme.of(context).textTheme.headline1!.color)),
          LayoutBuilder(builder: (context, constraints) {
            if (widget.subfoodcategory != "") {
              //If there is a sub food category, show it
              return Text(" · ${widget.subfoodcategory}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).textTheme.headline1!.color));
            } else {
              //If there isnt a sub-food category, dont show it
              return const Text("");
            }
          })
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Text(
            widget.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).textTheme.headline6!.color,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    )));
  }
}
