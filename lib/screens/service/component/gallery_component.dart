import 'package:booking_system_flutter/screens/provider/zoom_image_screen.dart';
import 'package:booking_system_flutter/utils/widgets/cached_nework_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class GalleryComponent extends StatelessWidget {
  final List<String> images;
  final int index;
  final int? padding;

  GalleryComponent({required this.images, required this.index, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ZoomImageScreen(galleryImages: images, index: index).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 200.milliseconds);
      },
      child: cachedImage(images[index], height: 100, width: context.width() / 3 - (padding ?? 22), fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius),
    );
  }
}
