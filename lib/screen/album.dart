import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PhotoGalleryApp extends StatefulWidget {
  const PhotoGalleryApp({super.key});

  @override
  State<PhotoGalleryApp> createState() => _PhotoGalleryAppState();
}

class _PhotoGalleryAppState extends State<PhotoGalleryApp> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> currentPhotos = [];
  String selectedAlbum = "앨범 정보를 불러오는 중"; // 선택된 앨범

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      final List<AssetPathEntity> fetchedAlbums = await PhotoManager.getAssetPathList();
      final List<AssetEntity> allPhotos = await fetchedAlbums[0].getAssetListPaged(page: 0, size: 100);

      setState(() {
        albums = fetchedAlbums;
        currentPhotos = allPhotos;
        selectedAlbum = fetchedAlbums[0].name;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  void _selectAlbum(String albumName) async {
    final selected = albums.firstWhere((album) => album.name == albumName);
    final List<AssetEntity> albumPhotos =
    await selected.getAssetListPaged(page: 0, size: 100);
    setState(() {
      selectedAlbum = albumName;
      currentPhotos = albumPhotos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedAlbum,
            items: albums.map((album) => album.name).toSet().map((album) {
              return DropdownMenuItem(
                value: album,
                child: Text(album),
              );
            }).toList(),
            underline: const SizedBox.shrink(),
            onChanged: (newValue) => _selectAlbum(newValue!),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: Image.asset(
                        'assets/loop_logo.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  },
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
