import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_list_model.dart';
import 'package:booking_system_flutter/screens/booking/widgets/edit_booking_service_dialog.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/string_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/widgets/cached_nework_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingItemWidget extends StatelessWidget {
  final Booking data;

  BookingItemWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    Widget _buildEditBookingWidget() {
      if (data.status == BookingStatusKeys.pending && DateTime.parse(data.date.validate()).isAfter(DateTime.now())) {
        return IconButton(
          icon: ic_edit_square.iconImage(size: 20),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            showInDialog(
              context,
              contentPadding: EdgeInsets.zero,
              hideSoftKeyboard: true,
              backgroundColor: context.cardColor,
              builder: (p0) {
                return AppCommonDialog(
                  title: "Edit Service",
                  child: EditBookingServiceDialog(data: data),
                );
              },
            );
          },
        );
      }
      return Offstage();
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(border: Border.all(color: context.dividerColor), borderRadius: radius()),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cachedImage(
                data.service_attchments!.isNotEmpty ? data.service_attchments!.first.validate() : '',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ).cornerRadiusWithClipRRect(defaultRadius),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: data.status_label.validate().getPaymentStatusBackgroundColor.withOpacity(0.1),
                              borderRadius: radius(),
                            ),
                            child: Text(
                              data.status_label.validate(),
                              style: boldTextStyle(color: data.status_label.validate().getPaymentStatusBackgroundColor, size: 12),
                            ),
                          ),
                          _buildEditBookingWidget(),
                        ],
                      ),
                      Text('#${data.id.validate()}', style: boldTextStyle(color: primaryColor, size: 16)),
                    ],
                  ),
                  8.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.service_name.validate(),
                        style: boldTextStyle(size: 16),
                        overflow: TextOverflow.ellipsis,
                      ).expand(),
                    ],
                  ),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PriceWidget(
                        price: data.isHourlyService
                            ? data.total_amount.validate()
                            : calculateTotalAmount(
                                servicePrice: data.price.validate(),
                                qty: data.quantity.validate(),
                                couponData: data.coupon_data != null ? data.coupon_data : null,
                                taxes: data.taxes.validate(),
                                serviceDiscountPercent: data.discount.validate(),
                              ),
                        color: primaryColor,
                        isHourlyService: data.isHourlyService,
                        size: 18,
                      ),
                      if (data.isHourlyService.toString().validate() == SERVICE_TYPE_HOURLY) 4.width else 8.width,
                      if (data.discount != null && data.discount != 0)
                        Row(
                          children: [
                            Text('(${data.discount.validate()}%', style: boldTextStyle(size: 14, color: Colors.green)),
                            Text(' ${language!.lblOff})', style: boldTextStyle(size: 14, color: Colors.green)),
                          ],
                        ),
                    ],
                  ),
                ],
              ).expand(),
            ],
          ).paddingAll(8),
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            margin: EdgeInsets.all(8),
            //decoration: cardDecoration(context),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${language!.lblDate} & ${language!.lblTime}', style: secondaryTextStyle()),
                    8.width,
                    Text(
                      "${formatDate(data.date.validate(), format: DATE_FORMAT_2)} At ${formatDate(data.date.validate(), format: Hour12Format)}",
                      style: boldTextStyle(size: 14),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ).expand(),
                  ],
                ).paddingAll(8),
                if (data.customer_name.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(language!.customerName, style: secondaryTextStyle()),
                          8.width,
                          Text(data.customer_name.validate(), style: boldTextStyle(size: 14), textAlign: TextAlign.right).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (data.provider_name.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(language!.lblProvider, style: secondaryTextStyle()),
                          8.width,
                          Text(data.provider_name.validate(), style: boldTextStyle(size: 14), textAlign: TextAlign.right).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (data.handyman.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language!.textHandyman, style: secondaryTextStyle()),
                          Text(data.handyman!.validate().first.handyman!.display_name.validate(), style: boldTextStyle(size: 14)).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (data.payment_status != null)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language!.paymentStatus, style: secondaryTextStyle()).expand(),
                          Text(
                            buildPaymentStatusWithMethod(data.payment_status.validate(), data.payment_method.validate()),
                            style: boldTextStyle(size: 14, color: data.payment_status.validate() == SERVICE_PAYMENT_STATUS_PAID ? Colors.green : Colors.red),
                          ),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
              ],
            ).paddingAll(8),
          ),
        ],
      ),
    );
  }
}
