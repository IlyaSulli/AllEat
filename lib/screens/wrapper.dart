import 'package:alleat/screens/fresh_app/fresh_profile.dart';
import 'package:alleat/services/sqlite_service.dart';
import 'package:alleat/widgets/apperror.dart';
import 'package:alleat/widgets/genericload.dart';
import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/material.dart';

class SetupWrapper extends StatefulWidget {
  const SetupWrapper({Key? key}) : super(key: key);

  @override
  State<SetupWrapper> createState() => _SetupWrapperState();
}

class _SetupWrapperState extends State<SetupWrapper> {
  //Default setup not complete if something wrong happens
  bool setup = false;

  Future<bool> isSetupComplete() async {
    List<Map> profileInfo = await SQLiteLocalDB
        .getFirstProfile(); //Call Database for the first entry
    if (profileInfo.isEmpty) {
      //If the first entry is empty
      //Then setup is not complete (pass to build)
      return false;
    } else {
      //If the first entry exists
      //Setup is complete (pass to build)
      return true;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: isSetupComplete(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            //While loading, go to loading page
            return const GenericLoading();
          }
          if (snapshot.hasError) {
            //If the app has an error, go to error page
            return const AppError();
          } else {
            bool setup = snapshot.data ?? [] as bool; //Get data from Future
            if (setup == false) {
              //If setup is not complete
              return const FreshProfile(); //Go to Setup page
            } else if (setup == true) {
              //If setup is complete
              return const Navigation(); //Go to main page
            } else {
              //If there is an error
              return const AppError(); // Go to error page
            }
          }
        },
      );
}
