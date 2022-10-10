import 'package:flutter/material.dart';

class RestaurantItemCustomisePage extends StatefulWidget {
  final String itemid;
  final String foodcategory;
  final String subfoodcategory;
  final String itemname;
  final String description;
  final String price;
  final String itemimage;
  const RestaurantItemCustomisePage(
      {Key?
          key, //Get the items from the restaurant main page when an item is clicked
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
    return MaterialApp(
        //Create new screen
        title: widget.itemname,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(widget.itemname), //Title is the name of the item
              leading: IconButton(
                  //Back button

                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: SingleChildScrollView(
              child: SizedBox(
                child: Column(children: [
                  Padding(
                      //Restaurant Banner
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: NetworkImage(widget.itemimage),
                          ),
                        ),
                      )),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20, bottom: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        flex: 8, // 8/10 asigned to item name
                                        child: Text(
                                            //Restaurant Text
                                            widget.itemname,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w600))),
                                    Flexible(
                                        //Restaurant price
                                        flex: 2, // 2/10 asigned to price
                                        child: Text("£${widget.price}",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff5806FF)))),
                                  ],
                                )),
                            Padding(
                                //Categories
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Row(children: [
                                  Text(
                                      widget
                                          .foodcategory, //Must have food category
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff5806FF))),
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    if (widget.subfoodcategory != "") {
                                      //If there is a sub food category, show it
                                      return Text(
                                          " · ${widget.subfoodcategory}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff5806FF)));
                                    } else {
                                      //If there isnt a sub-food category, dont show it
                                      return const Text("");
                                    }
                                  })
                                ])),
                            Padding(
                                //Restaurant logo, text and favourites button below restaurant banner
                                padding: const EdgeInsets.only(
                                    left: 20, right: 30, bottom: 15, top: 20),
                                child: Text(
                                    //Restaurant Text
                                    widget.description,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)))
                          ])),
                ]),
              ),
            )));
  }
}
