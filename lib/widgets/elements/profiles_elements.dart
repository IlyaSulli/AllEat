import 'package:alleat/services/localprofiles_service.dart';
import 'package:flutter/material.dart';

class ProfileList extends StatefulWidget {
  const ProfileList({super.key});

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  bool edit = false;

  Future<List> getDisplayableProfiles() async {
    return await SQLiteLocalProfiles.getDisplayUnselected();
  }

  Future<List> getSelectedDisplayableProfile() async {
    return await SQLiteLocalProfiles.getDisplaySelected();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
          FutureBuilder<List>(
              future: getSelectedDisplayableProfile(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .navigationBarTheme
                                  .backgroundColor))
                    ],
                  );
                } else if (snapshot.hasData) {
                  List? profileInfo = snapshot.data;
                  if (profileInfo != null && profileInfo.isNotEmpty) {
                    return SizedBox(
                        width: (profileInfo.length + 1) * 80,
                        child: ListView.builder(
                            itemCount: profileInfo.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> profile = profileInfo[index];
                              String displayChar = profile['firstname'];
                              displayChar.substring(0, 1);
                              return Column(children: [
                                Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 3,
                                            style: BorderStyle.solid),
                                        color: Color(
                                            profile['profilecolor'].hashCode)),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            '${profile['firstname'][0]}${profile['firstname'][1]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3))),
                                const SizedBox(height: 20),
                                SizedBox(
                                    width: 100,
                                    child: Text(
                                      "${profile['firstname']}\n${profile['lastname']}",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                      overflow: TextOverflow.ellipsis,
                                    ))
                              ]);
                            }));
                  } else {
                    return Column(
                      children: [
                        Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).errorColor))
                      ],
                    );
                  }
                } else {
                  return Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).errorColor))
                    ],
                  );
                }
              }),
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).backgroundColor,
                  size: 30,
                ),
              )
            ],
          )
        ]));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Row(children: [
  //     FutureBuilder<List>(
  //         future: getSelectedDisplayableProfile(),
  //         builder: (context, snapshot) {
  //           if (!snapshot.hasData) {
  //             return Column(
  //               children: [
  //                 Container(
  //                   width: 80,
  //                   height: 80,
  //                   decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: Theme.of(context).bottomAppBarColor),
  //                 )
  //               ],
  //             );
  //           } else if (snapshot.hasData) {
  //             List? profileinfo = snapshot.data;
  //             if (profileinfo != null && profileinfo.isNotEmpty) {
  //               print(profileinfo);
  //               return Container(
  //                   width: 100,
  //                   height: 200.0,
  //                   child: ListView.builder(
  //                       itemCount: profileinfo.length,
  //                       scrollDirection: Axis.horizontal,
  //                       itemBuilder: (context, index) {
  //                         Map<String, dynamic> profile = profileinfo[index];
  //                         String displayChar = profile['firstname'];
  //                         displayChar.substring(0, 1);
  //                         return Column(children: [
  //                           Container(
  //                               width: 80,
  //                               height: 80,
  //                               decoration: BoxDecoration(
  //                                   shape: BoxShape.circle,
  //                                   border: Border.all(
  //                                       color: Theme.of(context).primaryColor,
  //                                       width: 3,
  //                                       style: BorderStyle.solid),
  //                                   color: Color(
  //                                       profile['profilecolor'].hashCode)),
  //                               child: Align(
  //                                   alignment: Alignment.center,
  //                                   child: Text(
  //                                       '${profile['firstname'][0]}${profile['firstname'][1]}',
  //                                       style: Theme.of(context)
  //                                           .textTheme
  //                                           .headline3))),
  //                           const SizedBox(height: 20),
  //                           SizedBox(
  //                               width: 100,
  //                               child: Text(
  //                                 "${profile['firstname']}\n${profile['lastname']}",
  //                                 textAlign: TextAlign.center,
  //                                 style: Theme.of(context)
  //                                     .textTheme
  //                                     .headline4
  //                                     ?.copyWith(
  //                                         fontWeight: FontWeight.w600,
  //                                         color:
  //                                             Theme.of(context).primaryColor),
  //                                 overflow: TextOverflow.ellipsis,
  //                               ))
  //                         ]);
  //                       }));
  //             } else {
  //               return Column(
  //                 children: [
  //                   Container(
  //                     width: 80,
  //                     height: 80,
  //                     decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         color: Theme.of(context).errorColor),
  //                   )
  //                 ],
  //               );
  //             }
  //           } else {
  //             return Column(
  //               children: [
  //                 Container(
  //                   width: 80,
  //                   height: 80,
  //                   decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: Theme.of(context).errorColor),
  //                 )
  //               ],
  //             );
  //           }
  //         }),
  //   ]);
  // }
}
