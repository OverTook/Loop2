import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaGrid extends StatefulWidget {
  const MediaGrid({super.key});

  @override
  State<MediaGrid> createState() => _MediaGridState();
}
class _MediaGridState extends State<MediaGrid> {

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  _fetchNewMedia() async {
    var result = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption()
    );
    debugPrint(result.toString());
    debugPrint((result == PermissionState.limited).toString());
    debugPrint((result == PermissionState.authorized || result == PermissionState.limited).toString());

    if (result == PermissionState.authorized) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
      debugPrint(albums.toString());
    } else {
      PhotoManager.openSetting();
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}