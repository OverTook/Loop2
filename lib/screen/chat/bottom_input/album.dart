import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../album.dart';

class MediaGrid extends StatefulWidget {
  const MediaGrid({super.key});

  @override
  State<MediaGrid> createState() => _MediaGridState();
}
class _MediaGridState extends State<MediaGrid> {
  List<AssetEntity> assets = []; // 사진을 담을 리스트
  bool isLimited = false;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  _fetchNewMedia() async {
    var result = await PhotoManager.requestPermissionExtend();
    debugPrint(result.toString());
    debugPrint((result == PermissionState.limited).toString());
    debugPrint((result == PermissionState.authorized || result == PermissionState.limited).toString());

    if (result == PermissionState.authorized || result == PermissionState.limited) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> assets = await albums.first.getAssetListPaged(
        page: 0,
        size: 100,
      );

      setState(() {
        this.assets = assets;
        isLoaded = true;
        isLimited = result == PermissionState.limited;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 48), // 버튼 높이만큼 여백 추가
          child: !isLoaded
              ? const Center(child: CircularProgressIndicator(color: Colors.black54,))
              : AlbumCarousel(assets: assets),
        ),

        Positioned(
          left: 2,
          bottom: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhotoGalleryApp()),
              );
            },
            child: const Row(
              children: [
                Icon(
                  Icons.grid_view_rounded
                ),
                SizedBox(width: 5),
                Text("전체보기"),
              ],
            ),
          ),
        ),

        isLimited ? Positioned(
          right: 0,
          bottom: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              PhotoManager.openSetting();
            },
            child: const Text("제한된 권한"),
          ),
        ) : const SizedBox()
      ],
    );


  }
}

class AlbumCarousel extends StatelessWidget {
  final List<AssetEntity> assets;

  const AlbumCarousel({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0), // 아이템 간 간격
          child: AspectRatio(
            aspectRatio: 1,
            child: Image(
              image: AssetEntityImageProvider(asset, isOriginal: false),
              fit: BoxFit.cover, // 이미지 크기 조정
              height: MediaQuery.of(context).size.height * 0.4, // 부모 높이의 40%
            ),
          ),
        );
      },
    );
  }
}
