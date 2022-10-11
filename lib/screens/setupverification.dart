import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/widgets/genericlocading.dart';
import 'package:alleat/widgets/navigationbar.dart';

class SetupWrapper {
  bool setup = false;
  Future isSetupComplete() async {
    List profileInfo = await SQLiteLocalProfiles.getFirstProfile();
    //Call Database for the first entry
    if (profileInfo.isNotEmpty) {
      //If the first entry is empty
      //Then setup is not complete (pass to build)
      const Navigation();
    } else {
      //If the first entry exists
      //Setup is complete (pass to build)

      const GenericLoading();
      //return const FreshProfile();
    }
  }
}
