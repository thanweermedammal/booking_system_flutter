import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/screens/provider/zoom_image_screen.dart';
import 'package:booking_system_flutter/utils/widgets/cached_nework_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceProofListWidget extends StatelessWidget {
  final ServiceProof data;

  ServiceProofListWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.title.validate().isNotEmpty) Text(data.title.validate(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (data.description.validate().isNotEmpty)
            Column(
              children: [
                8.height,
                Text(data.description.validate(), style: secondaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          if (data.attachments.validate().isNotEmpty)
            Column(
              children: [
                16.height,
                HorizontalList(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  itemCount: data.attachments!.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (_, i) {
                    return Container(
                      decoration: boxDecorationRoundedWithShadow(10),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: cachedImage(
                        data.attachments![i].validate(),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ).onTap(() {
                      ZoomImageScreen(galleryImages: data.attachments!, index: i).launch(context);
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
