import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PhotoGalleryApp extends StatefulWidget {
  @override
  _PhotoGalleryAppState createState() => _PhotoGalleryAppState();
}

class _PhotoGalleryAppState extends State<PhotoGalleryApp> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> currentPhotos = [];
  bool isViewingAll = true; // 기본적으로 "전체보기" 상태
  String? selectedAlbum; // 선택된 앨범

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      final List<AssetPathEntity> fetchedAlbums =
      await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      final List<AssetEntity> allPhotos =
      await fetchedAlbums[0].getAssetListPaged(page: 0, size: 100); // 전체 사진 가져오기

      setState(() {
        albums = fetchedAlbums;
        currentPhotos = allPhotos;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  void _selectAlbum(String? albumName) async {
    if (albumName == "전체보기") {
      final List<AssetEntity> allPhotos =
      await albums[0].getAssetListPaged(page: 0, size: 100);
      setState(() {
        isViewingAll = true;
        selectedAlbum = null;
        currentPhotos = allPhotos;
      });
    } else {
      final selected = albums.firstWhere((album) => album.name == albumName);
      final List<AssetEntity> albumPhotos =
      await selected.getAssetListPaged(page: 0, size: 100);
      setState(() {
        isViewingAll = false;
        selectedAlbum = albumName;
        currentPhotos = albumPhotos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedAlbum ?? "전체보기"),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                currentPhotos = [];
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 앨범 선택 드롭다운
          DropdownButton<String>(
            value: isViewingAll ? "전체보기" : selectedAlbum,
            items: [
              DropdownMenuItem(
                value: "전체보기",
                child: Text("전체보기"),
              ),
              ...albums.map((album) {
                return DropdownMenuItem(
                  value: album.name,
                  child: Text(album.name),
                );
              }).toList(),
            ],
            onChanged: _selectAlbum,
          ),
          // 사진 리스트
          Expanded(
            child: currentPhotos.isEmpty
                ? const Center(child: Text("사진이 없습니다."))
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 한 행에 4개의 사진
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: currentPhotos.length,
              itemBuilder: (context, index) {
                return Image(
                  image: AssetEntityImageProvider(currentPhotos[index]),
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
