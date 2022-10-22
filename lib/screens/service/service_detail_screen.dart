import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/component/read_more_text.dart' as read;
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_detail_model.dart';
import 'package:booking_system_flutter/model/service_model.dart';
import 'package:booking_system_flutter/model/user_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/booking/book_sercive_screen.dart';
import 'package:booking_system_flutter/screens/booking/widgets/booking_detail_provider_widget.dart';
import 'package:booking_system_flutter/screens/provider/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/service/component/gallery_component.dart';
import 'package:booking_system_flutter/screens/service/component/gallery_service.dart';
import 'package:booking_system_flutter/screens/service/component/review_widget.dart';
import 'package:booking_system_flutter/screens/service/service_faq_all_screen.dart';
import 'package:booking_system_flutter/screens/service/widgets/service_component.dart';
import 'package:booking_system_flutter/screens/service/widgets/service_faq_widget.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/extensions/string_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/widgets/cached_nework_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  ServiceDetailScreen({required this.serviceId});

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  PageController pageController = PageController();

  int selectedAddressId = 0;
  int selectedBookingAddressId = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget imageAndNameWidget({required ServiceDetail data}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (data.attchments!.isNotEmpty)
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: pageController,
              itemCount: data.attchments!.length,
              itemBuilder: (context, index) =>
                  cachedImage(data.attchments![index], fit: BoxFit.cover),
            ),
          )
        else
          SizedBox(height: 400, child: cachedImage("")),
        if (data.attchments!.isNotEmpty && data.attchments!.length != 1)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: DotIndicator(
                pageController: pageController,
                pages: data.attchments.validate()),
          ),
        Positioned(top: context.statusBarHeight, child: BackWidget()),
        Positioned(
          top: context.statusBarHeight + 8,
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 8),
            decoration: boxDecorationWithShadow(
                boxShape: BoxShape.circle, backgroundColor: context.cardColor),
            child: data.isFavourite == 1
                ? ic_fill_heart.iconImage(color: favouriteColor, size: 24)
                : ic_heart.iconImage(color: unFavouriteColor, size: 24),
          ).onTap(() async {
            if (data.isFavourite == 1) {
              data.isFavourite = 0;
              setState(() {});

              await removeToWishList(serviceId: data.id.validate())
                  .then((value) {
                if (!value) {
                  data.isFavourite = 1;
                  setState(() {});
                }
              });
            } else {
              data.isFavourite = 1;
              setState(() {});

              await addToWishList(serviceId: data.id.validate()).then((value) {
                if (!value) {
                  data.isFavourite = 0;
                  setState(() {});
                }
              });
            }
          }),
          right: 8,
        ),
      ],
    );
  }

  Widget descriptionWidget({required ServiceDetail data}) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: context.width(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language!.hintDescription, style: boldTextStyle()),
              16.height,
              data.description.validate().isNotEmpty
                  ? ReadMoreText(
                      data.description.validate(),
                      style: secondaryTextStyle(),
                    )
                  : Text(language!.lblNotDescription,
                      style: secondaryTextStyle()),

              //Text(data.description.validate(), style: secondaryTextStyle()),
            ],
          ).paddingOnly(top: 130, bottom: 0, left: 16, right: 16),
          Positioned(
            top: -100,
            left: 16,
            right: 16,
            child: Container(
              width: context.width(),
              padding: EdgeInsets.all(16),
              decoration: boxDecorationDefault(
                color: context.scaffoldBackgroundColor,
                border: Border.all(color: context.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.subCategoryName.validate().isNotEmpty)
                    Text('${data.categoryName} > ${data.subCategoryName}',
                        style: boldTextStyle(size: 14, color: primaryColor))
                  else
                    Text('${data.categoryName}',
                        style: boldTextStyle(size: 14, color: primaryColor)),
                  6.height,
                  Marquee(
                    child: Text('${data.name.validate()}',
                        style: boldTextStyle(size: 20)),
                    directionMarguee: DirectionMarguee.oneDirection,
                  ),
                  8.height,
                  Row(
                    children: [
                      PriceWidget(
                          price: data.price.validate(),
                          isHourlyService: data.isHourlyService,
                          size: 24,
                          hourlyTextColor: primaryColor),
                      4.width,
                      if (data.discount.validate() != 0)
                        Text(
                          '(${data.discount.validate()}% Off)',
                          style: boldTextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                  8.height,
                  TextIcon(
                    edgeInsets:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    text: '${language!.duration}',
                    expandedText: true,
                    suffix: Text(
                        "${data.duration.validate()} ${language!.lblHour}",
                        style: boldTextStyle(color: primaryColor)),
                  ),
                  TextIcon(
                    text: '${language!.lblRating}',
                    edgeInsets:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    expandedText: true,
                    suffix: Row(
                      children: [
                        Image.asset('images/icons/ic_star_fill.png',
                            height: 18),
                        4.width,
                        Text(
                            "${data.totalRating.validate().toStringAsFixed(1)}",
                            style: boldTextStyle()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget availableWidget({required ServiceDetail data}) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text(language!.lblAvailableAt, style: boldTextStyle()),
          16.height,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              data.serviceAddressMapping!.length,
              (index) {
                ServiceAddressMapping value =
                    data.serviceAddressMapping![index];
                bool isSelected = selectedAddressId == index;
                if (selectedBookingAddressId == -1) {
                  selectedBookingAddressId = data
                      .serviceAddressMapping!.first.providerAddressId
                      .validate();
                }
                return GestureDetector(
                  onTap: () {
                    selectedAddressId = index;
                    selectedBookingAddressId =
                        value.providerAddressId.validate();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationDefault(
                        color: isSelected ? primaryColor : context.cardColor),
                    child: Text(
                      '${value.providerAddressMapping!.address.validate()}',
                      style: boldTextStyle(
                          color: isSelected
                              ? Colors.white
                              : textPrimaryColorGlobal),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget providerWidget({required UserData data}) {
    return BookingDetailProviderWidget(providerData: data).onTap(() {
      ProviderInfoScreen(providerId: data.id).launch(context);
    }).paddingAll(16);
  }

  Widget galleryWidget({required ServiceDetail data}) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: context.width(),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${language!.lblGallery} (${data.attchments!.length.toString()})',
                  style: boldTextStyle()),
              //Text(language!.lblGallery, style: boldTextStyle(size: 18)).expand(),
              if (data.attchments!.length > 1)
                TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero)),
                  onPressed: () {
                    GalleryScreen(
                      serviceName: data.name.validate(),
                      attachments: data.attchments.validate(),
                    ).launch(context,
                        pageRouteAnimation: PageRouteAnimation.Slide,
                        duration: 400.milliseconds);
                  },
                  child:
                      Text(language!.lblViewAll, style: secondaryTextStyle()),
                ),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              data.attchments!.take(3).length,
              (i) => GalleryComponent(
                  images: data.attchments!, index: i, padding: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewWidget({required List<RatingData> data}) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(language!.review, style: boldTextStyle(size: 18)).expand(),
              if (data.length > 1)
                TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero)),
                  onPressed: () {
                    RatingViewAllScreen(ratingData: data).launch(context);
                  },
                  child:
                      Text(language!.lblViewAll, style: secondaryTextStyle()),
                ),
            ],
          ),
          16.height,
          data.isNotEmpty
              ? Wrap(
                  children: List.generate(
                    data.take(5).length,
                    (index) => ReviewWidget(data: data[index]),
                  ),
                )
              : Text(language!.lblNoReviews, style: secondaryTextStyle())
                  .paddingOnly(top: 16),
        ],
      ),
    );
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(language!.lblFaq, style: boldTextStyle(size: 18)).expand(),
              if (data.length > 3)
                TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero)),
                  onPressed: () {
                    ServiceFaqAllScreen(data: data).launch(context);
                  },
                  child:
                      Text(language!.lblViewAll, style: secondaryTextStyle()),
                ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.take(3).length,
            padding: EdgeInsets.all(0),
            itemBuilder: (_, index) =>
                ServiceFaqWidget(serviceFaq: data[index]),
          ),
        ],
      ),
    );
  }

  Widget relatedServiceWidget(
      {required List<Service> serviceList, required int serviceId}) {
    serviceList.removeWhere((element) => element.id == serviceId);
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language!.lblRelatedServices, style: boldTextStyle(size: 18)),
          16.height,
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: List.generate(serviceList.take(10).length, (index) {
              Service data = serviceList[index];
              return ServiceComponent(
                  serviceData: data, width: context.width() / 2 - 24);
            }),
          )
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageAndNameWidget(data: snap.data!.service_detail!),
                  descriptionWidget(data: snap.data!.service_detail!),
                  16.height,
                  if (snap
                      .data!.service_detail!.serviceAddressMapping!.isNotEmpty)
                    availableWidget(data: snap.data!.service_detail!),
                  providerWidget(data: snap.data!.provider!),
                  if (snap.data!.service_detail!.attchments
                      .validate()
                      .isNotEmpty)
                    galleryWidget(data: snap.data!.service_detail!),
                  if (snap.data!.serviceFaq.validate().isNotEmpty)
                    serviceFaqWidget(data: snap.data!.serviceFaq.validate()),
                  reviewWidget(data: snap.data!.rating_data!),
                  24.height,
                  if (snap.data!.realted_service!.length == 1 &&
                      snap.data!.realted_service!
                          .contains(snap.data!.service_detail!.id.validate()))
                    relatedServiceWidget(
                        serviceList: snap.data!.realted_service.validate(),
                        serviceId: snap.data!.service_detail!.id.validate()),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AppButton(
                onTap: () {
                  if (appStore.isLoggedIn) {
                    snap.data!.service_detail!.bookingAddressId =
                        selectedBookingAddressId;
                    BookServiceScreen(data: snap.data!).launch(context);
                  } else {
                    SignInScreen().launch(context);
                  }
                },
                color: context.primaryColor,
                text: language!.lblBookNow,
                width: context.width(),
                textColor: Colors.white,
              ),
            )
          ],
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<ServiceDetailResponse>(
      future: getServiceDetails(
          serviceId: widget.serviceId.validate(), customerId: appStore.userId),
      builder: (context, snap) {
        return Scaffold(
          body: buildBodyWidget(snap),
          floatingActionButton: (snap.hasData &&
                  snap.data!.service_detail!.isFeatured.validate(value: 0) == 1)
              ? FloatingActionButton(
                  onPressed: () {
                    toast(language!.lblFeaturedProduct);
                  },
                  child: ic_featured.iconImage(color: Colors.white),
                ).paddingBottom(60)
              : Offstage(),
        );
      },
    );
  }
}
