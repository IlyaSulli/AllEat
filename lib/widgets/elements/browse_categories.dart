import 'package:alleat/widgets/elements/elements.dart';
import 'package:flutter/material.dart';

List categoriesList = [
  [
    "Burgers",
    const Color(0xffFFD8C2),
    'lib/assets/images/categories/burger-category.png'
  ],
  [
    "American",
    const Color(0xffeec4c4),
    'lib/assets/images/categories/american-category.png'
  ],
  [
    "Breakfast",
    const Color(0xffc6f0d9),
    'lib/assets/images/categories/breakfast-category.png'
  ],
  [
    "Sushi",
    const Color(0xffc2f7a9),
    'lib/assets/images/categories/sushi-category.png'
  ],
  [
    "Chinese",
    const Color(0xffffeec2),
    'lib/assets/images/categories/chinese-category.png'
  ],
  [
    "Thai",
    const Color(0xfff8c6aa),
    'lib/assets/images/categories/thai-category.png'
  ],
  [
    "Coffee",
    const Color(0xfff0c6df),
    'lib/assets/images/categories/coffee-category.png'
  ],
  [
    "Greek",
    const Color(0xffc6e1f0),
    'lib/assets/images/categories/greek-category.png'
  ],
];

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //Create profile selection widget with height 150px
        height: 170,
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: const EdgeInsets.only(left: 25),
                child: SizedBox(
                    width: 825,
                    child: ListView.builder(
                        itemCount: 5,
                        scrollDirection: Axis.horizontal, //Make scrollable list
                        itemBuilder: (context, index) {
                          List category = categoriesList[index];
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              child: InkWell(
                                  onTap: (() {}),
                                  child: Stack(
                                      alignment: AlignmentDirectional.topCenter,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            color: category[1],
                                          ),
                                          width: 150,
                                          height: 170,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  category[0],
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .copyWith(
                                                          color: const Color(
                                                              0xff000000)),
                                                ))),
                                        Image.asset(
                                          //Fullscreen image of food
                                          category[2],
                                          alignment: Alignment.bottomRight,
                                        ),
                                      ])));
                        })))
          ])
        ]));
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ScreenBackButton(),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "All Categories.",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline2,
                )),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 40, top: 20, left: 20, right: 20),
              child: SizedBox(
                  height: (categoriesList.length * 185) / 2.ceil(),
                  child: GridView.builder(
                      itemCount: categoriesList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 0.0,
                              mainAxisSpacing: 10.0),
                      itemBuilder: (context, index) {
                        List category = categoriesList[index];
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: InkWell(
                                onTap: (() {}),
                                child: Stack(
                                    alignment: AlignmentDirectional.topCenter,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: category[1],
                                        ),
                                        width: 150,
                                        height: 170,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                category[0],
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                        color: const Color(
                                                            0xff000000)),
                                              ))),
                                      Image.asset(
                                        //Fullscreen image of food
                                        category[2],
                                        alignment: Alignment.bottomRight,
                                      ),
                                    ])));
                      })),
            )
          ]),
        )
      ]),
    );
  }
}
