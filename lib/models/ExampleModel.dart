import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ExampleModel {
  final String name;
  final String? imageAddress;
  final ItemType itemType;
  final double latitude;
  final double longitude;
  bool isOnFocus = false;
  //BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  final String district;
  final String? description;

  ExampleModel(this.name, this.imageAddress, this.itemType, this.latitude,
      this.longitude, this.district, this.description);

  setCustomMarker() async {
    if (imageAddress != null) {
      try {
        //customIcon = await getMarkerIcon(imageAddress!);
      } catch (e) {}
    }
  }

  /*Future<BitmapDescriptor> getMarkerIcon(String imageUrl) async {
    const int size = 150;
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(imageUrl);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    final Codec markerImageCodec = await instantiateImageCodec(
      markerImageBytes,
      targetWidth: size,
    );

    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );

    final Uint8List? resizedMarkerImageBytes = byteData?.buffer.asUint8List();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Size canvasSize = Size(size.toDouble(), size.toDouble());
    final image = await decodeImageFromList(resizedMarkerImageBytes!);
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        const Radius.circular(100)));
    canvas.clipPath(clipPath);
    paintImage(
        fit: BoxFit.cover,
        canvas: canvas,
        image: image,
        rect: Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    final markerAsImage =
        await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? finalByteData =
        await markerAsImage.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(finalByteData!.buffer.asUint8List());
  }*/

  void onItemClicked() {
    isOnFocus = !isOnFocus;
    //setCustomMarker();
  }

  factory ExampleModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ExampleModel(
        data["name"],
        data["imageAddress"],
        ItemType.values.byName(data["type"]),
        double.parse(data["latitude"]),
        data["longitude"] != null ? double.parse(data["longitude"]) : 38.0,
        data["district"],
        data["description"]);
  }
}

enum ItemType {
  artifact,
  restaurant,
  hotel,
  none,
}
